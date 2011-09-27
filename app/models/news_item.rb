class NewsItem < ActiveRecord::Base
  validates_presence_of :title, :description, :link, :published_at, :guid, :rss_feed_id
  validates_uniqueness_of :guid, :scope => :rss_feed_id
  belongs_to :rss_feed

  searchable do
    integer :rss_feed_id
    time :published_at
    text :title
    text :description do
      Nokogiri::HTML(description).inner_text.gsub(/[\t\n\r]/, ' ').squish
    end
  end

  class << self
    def search_for(query, rss_feeds, since = nil, page = 1)
      instrument_hash = {:model=> self.name, :term => query, :rss_feeds => rss_feeds.collect(&:name).join(',')}
      instrument_hash.merge!(:since => since) if since
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => instrument_hash) do
        search do
          fulltext query do
            highlight :title, :description, :fragment_size => 255, :merge_continuous_fragments => true
          end
          with(:rss_feed_id, rss_feeds.collect(&:id))
          with(:published_at).greater_than(since) if since
          order_by :published_at, :desc
          paginate :page => page, :per_page => 10
        end rescue nil
      end
    end
  end

end