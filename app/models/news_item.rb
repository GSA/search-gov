class NewsItem < ActiveRecord::Base
  validates_presence_of :title, :description, :link, :published_at, :guid, :rss_feed_id
  validates_uniqueness_of :guid, :scope => :rss_feed_id
  belongs_to :rss_feed
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
  end

  class << self
    include QueryPreprocessor

    def search_for(query, rss_feeds, since = nil, page = 1, excluded_urls = [])
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      instrument_hash = {:model=> self.name, :term => sanitized_query, :rss_feeds => rss_feeds.collect(&:name).join(',')}
      instrument_hash.merge!(:since => since) if since
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => instrument_hash) do
        search do
          fulltext preprocess(sanitized_query) do
            highlight :title, :description, :fragment_size => 255, :merge_continuous_fragments => true
          end
          with(:rss_feed_id, rss_feeds.collect(&:id))
          with(:published_at).greater_than(since) if since
          without(:link).any_of excluded_urls unless excluded_urls.empty?
          order_by :published_at, :desc
          paginate :page => page, :per_page => 10
        end rescue nil
      end
    end
  end

  def is_video?
    link =~ /^http:\/\/www.youtube.com\/watch\?v=.+$/i
  end
end