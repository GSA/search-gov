class NewsItem < ActiveRecord::Base
  validates_presence_of :title, :link, :published_at, :guid, :rss_feed_url_id
  validates_presence_of :description, :unless => :is_video?
  validates_format_of :link, with: /^https?:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?$/ix
  validates_uniqueness_of :guid, scope: :rss_feed_url_id, :case_sensitive => false
  validates_uniqueness_of :link, scope: :rss_feed_url_id, :case_sensitive => false
  before_validation :clean_text_fields
  belongs_to :rss_feed_url
  scope :recent, :order => 'published_at DESC', :limit => 10
  serialize :properties, Hash

  TIME_BASED_SEARCH_OPTIONS = ActiveSupport::OrderedHash.new
  TIME_BASED_SEARCH_OPTIONS["h"] = :hour
  TIME_BASED_SEARCH_OPTIONS["d"] = :day
  TIME_BASED_SEARCH_OPTIONS["w"] = :week
  TIME_BASED_SEARCH_OPTIONS["m"] = :month
  TIME_BASED_SEARCH_OPTIONS["y"] = :year

  searchable do
    integer :rss_feed_url_id
    time :published_at, :trie => true
    text(:title, stored: true) { CGI::escapeHTML(title ) }
    text(:description, stored: true) { CGI::escapeHTML(description) unless description.blank? }
    string :link
    string :contributor
    string :subject
    string :publisher
    string :tags, multiple: true
  end

  class << self
    include QueryPreprocessor
    def search_for(query, rss_feeds, affiliate, options = {})
      since_ts = options[:since]
      until_ts = options[:until]
      page = options[:page] || 1
      per_page = options[:per_page] || 10


      sanitized_query = preprocess(query)
      return nil if rss_feeds.blank?
      return nil if (rss_feed_url_ids = rss_feeds.map(&:rss_feed_urls).flatten.uniq.map(&:id)).blank?
      excluded_urls = affiliate.excluded_urls.collect { |url| url.url }
      instrument_hash = { model: self.name, term: sanitized_query, rss_feeds: rss_feeds.map(&:name).join(',') }
      instrument_hash.merge!(:since => since_ts) if since_ts
      instrument_hash.merge!(:until => until_ts) if until_ts
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => instrument_hash) do
        begin
          search do
            fulltext sanitized_query do
              highlight :title, :frag_list_builder => 'single'
              highlight :description, :fragment_size => 255
            end unless sanitized_query.blank?
            with(:rss_feed_url_id, rss_feed_url_ids)
            with(:published_at).greater_than(since_ts) if since_ts
            with(:published_at).less_than(until_ts) if until_ts
            without(:link).any_of excluded_urls unless excluded_urls.empty?
            with(:tags, options[:tags]) if options[:tags].present?

            [:contributor, :subject, :publisher].each do |facet_name|
              facet_restriction = nil
              facet_restriction = with(facet_name, options[facet_name]) if options[facet_name]
              facet(facet_name, exclude: facet_restriction)
            end

            order_by(:published_at, :desc) unless options[:sort_by_relevance]
            paginate :page => page, :per_page => per_page
          end
        rescue RSolr::Error::Http => e
          Rails.logger.warn "Error NewsItem#search_for: #{e.to_s}"
          nil
        end
      end
    end

    def title_description_date_hash_by_link(affiliate, urls)
      fields = [:link, :title, :description, :published_at]
      select(fields).where(rss_feed_url_id: affiliate.rss_feed_urls.map(&:id)).find_all_by_link(urls).reduce({}) do |result_hash, news_item|
        result_hash[news_item.link] = news_item
        result_hash
      end
    end
  end

  def is_video?
    link =~ /^#{Regexp.escape('http://www.youtube.com/watch?v=')}.+/i
  end

  def tags
    if properties.key?(:media_content) and
        properties[:media_content][:url].present? and
        properties.key?(:media_thumbnail) and
        properties[:media_thumbnail][:url].present?
      %w(image)
    else
      []
    end
  end

  def thumbnail_url
    properties[:media_thumbnail][:url] if properties[:media_thumbnail]
  end

  private

  def clean_text_fields
    %w(title description contributor subject publisher).each { |field| self.send(field+'=', clean_text_field(self.send(field))) }
  end

  def clean_text_field(str)
    str.squish if str.present?
  end
end
