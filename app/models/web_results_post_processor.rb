class WebResultsPostProcessor
  def initialize(query, affiliate, results)
    @affiliate = affiliate
    @results = results
    @news_item_hash = @affiliate.rss_feeds.non_managed.present? ? build_news_item_hash_from_search(query) : {}
    @link_hash = title_description_date_hash_by_link
  end

  def post_processed_results
    excluded_urls_empty = @affiliate.excluded_urls.empty?
    post_processed = @results.collect do |result|
      title, content = title_content_from_news_item(result.unescaped_url, @link_hash)
      title ||= result.title
      content ||= result.content
      if excluded_urls_empty || !url_is_excluded(result.unescaped_url)
        { 'title' => title,
          'content' => content,
          'unescapedUrl' => result.unescaped_url,
          'publishedAt' => (@link_hash[result.unescaped_url].published_at rescue nil) }
      else
        nil
      end
    end
    post_processed.compact
  end

  private

  def title_description_date_hash_by_link
    links_news_items = NewsItem.select([:link, :title, :description, :published_at]).
      where(rss_feed_url_id: @affiliate.rss_feed_urls.pluck(:id), link: @results.collect(&:unescaped_url)).
      map { |news_item| [news_item.link, news_item] }
    Hash[links_news_items]
  end

  def url_is_excluded(url)
    parsed_url = URI::parse(url) rescue nil
    return true if parsed_url and @affiliate.excludes_url?(url)
    false
  end

  def title_content_from_news_item(result_url, link_hash)
    news_item = @news_item_hash[result_url] || link_hash[result_url]
    [news_item.title, news_item.description] if news_item
  end

  def build_news_item_hash_from_search(query)
    news_search = ElasticNewsItem.search_for(q: query, rss_feeds: @affiliate.rss_feeds,
                                             excluded_urls: @affiliate.excluded_urls, language: @affiliate.locale)
    Hash[news_search.results.collect { |news_item| [news_item.link, news_item] }]
  end

end
