class WebResultsPostProcessor
  def initialize(query, affiliate, results)
    @affiliate =affiliate
    @results = results
    @news_item_hash = build_news_item_hash_from_search(query)
  end

  def post_processed_results
    link_hash = NewsItem.title_description_date_hash_by_link(@affiliate, @results.collect(&:unescaped_url))
    excluded_urls_empty = @affiliate.excluded_urls.empty?
    post_processed = @results.collect do |result|
      title, content = title_content_from_news_item(result.unescaped_url, link_hash)
      title ||= result.title
      content ||= result.content
      if excluded_urls_empty || !url_is_excluded(result.unescaped_url)
        {'title'=> title,
         'content'=> content,
         'unescapedUrl'=> result.unescaped_url,
         'publishedAt'=> (link_hash[result.unescaped_url].published_at rescue nil)}
      else
        nil
      end
    end
    post_processed.compact
  end

  private

  def url_is_excluded(url)
    parsed_url = URI::parse(url) rescue nil
    return true if parsed_url and @affiliate.excludes_url?(url)
    false
  end

  def title_content_from_news_item(result_url, link_hash)
    news_item_hit = @news_item_hash[result_url]
    if news_item_hit.present?
      [SolrBingHighlighter.hl(news_item_hit, :title), SolrBingHighlighter.hl(news_item_hit, :description)]
    else
      news_item = link_hash[result_url]
      [news_item.title, news_item.description] if news_item
    end
  end

  def build_news_item_hash_from_search(query)
    news_item_hash = {}
    news_items_overrides = NewsItem.search_for(query, @affiliate.rss_feeds)
    if news_items_overrides and news_items_overrides.total > 0
      news_items_overrides.each_hit_with_result do |news_item_hit, news_item_result|
        news_item_hash[news_item_result.link] = news_item_hit
      end
    end
    news_item_hash
  end

end