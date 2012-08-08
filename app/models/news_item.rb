class NewsItem < ActiveRecord::Base
  validates_presence_of :title, :link, :published_at, :guid, :rss_feed_id, :rss_feed_url_id
  validates_presence_of :description, :unless => :is_youtube_video?
  validates_uniqueness_of :guid, :scope => :rss_feed_id
  validates_uniqueness_of :link, :scope => :rss_feed_id
  before_validation :clean_text_fields
  belongs_to :rss_feed
  belongs_to :rss_feed_url
  scope :recent, :order => 'published_at DESC', :limit => 10

  TIME_BASED_SEARCH_OPTIONS = ActiveSupport::OrderedHash.new
  TIME_BASED_SEARCH_OPTIONS["h"] = :hour
  TIME_BASED_SEARCH_OPTIONS["d"] = :day
  TIME_BASED_SEARCH_OPTIONS["w"] = :week
  TIME_BASED_SEARCH_OPTIONS["m"] = :month
  TIME_BASED_SEARCH_OPTIONS["y"] = :year

  searchable do
    integer :rss_feed_id
    time :published_at, :trie => true
    text :title, :stored => true
    text :description, :stored => true
    string :link
    string :contributor
    string :subject
    string :publisher
  end

  class << self
    include QueryPreprocessor

    def search_for(query, rss_feeds, since = nil, page = 1, per_page = 10, contributor = nil, subject = nil, publisher = nil)
      sanitized_query = preprocess(query)
      return nil if rss_feeds.blank?
      excluded_urls = rss_feeds.first.affiliate.excluded_urls.collect { |url| url.url }
      instrument_hash = {:model => self.name, :term => sanitized_query, :rss_feeds => rss_feeds.collect(&:name).join(',')}
      instrument_hash.merge!(:since => since) if since
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => instrument_hash) do
        search do
          fulltext sanitized_query do
            highlight :title, :frag_list_builder => 'single'
            highlight :description, :fragment_size => 255
          end unless sanitized_query.blank?
          with(:rss_feed_id, rss_feeds.collect(&:id))
          with(:published_at).greater_than(since) if since
          without(:link).any_of excluded_urls unless excluded_urls.empty?

          %w(contributor subject publisher).each do |facet_name|
            facet_restriction = nil
            facet_restriction = with(facet_name.to_sym, eval(facet_name)) if eval(facet_name)
            facet(facet_name.to_sym, :exclude => facet_restriction)
          end

          order_by :published_at, :desc
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end
  end

  private

  def clean_text_fields
    %w(title description contributor subject publisher).each { |field| self.send(field+'=', clean_text_field(self.send(field))) }
  end

  def clean_text_field(str)
    str.squish if str.present?
  end

  def is_youtube_video?
    link =~ /^#{Regexp.escape('http://www.youtube.com/watch?v=')}.+/i
  end
end