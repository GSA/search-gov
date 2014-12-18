module Api::V2::SearchAsJson
  def as_json(_options = {})
    hash = {}
    as_json_append_web hash
    as_json_append_govbox_set hash
    hash
  end

  protected

  def as_json_append_web(hash)
    web_hash = {
      next_offset: @next_offset,
      results: as_json_results_to_hash
    }
    web_hash[:total] = @total if @total
    hash[:web] = web_hash
  end

  def as_json_append_govbox_set(hash)
    hash[:text_best_bets] = boosted_contents ? boosted_contents.results : []
    hash[:graphic_best_bets] = featured_collections ? featured_collections.results : []
    hash[:recent_tweets] = tweets ? tweets.results : []
    hash[:related_search_terms] = related_search ? related_search : []
    hash[:recent_video_news] = video_news_items ? as_json_recent_video_news : []
  end

  def as_json_results_to_hash
    @results.collect { |result| as_json_result_hash result }
  end

  def as_json_result_hash(result)
    { title: result.title,
      url: result.url,
      snippet: as_json_build_snippet(result.description) }
  end

  def as_json_build_snippet(description)
    if description =~ /\uE000/
      description.sub!(/^([^A-Z<])/, '...\1')
    else
      description = description.truncate(150, separator: ' ')
    end
    description
  end

  def as_json_recent_video_news
    video_news_items.results.collect do |news_item|
      news_item_hash = as_json_recent_news_item news_item, 'YouTube'
      news_item_hash.merge(thumbnail_url: news_item.youtube_thumbnail_url)
    end
  end

  def as_json_recent_news_item(news_item, source = nil)
    source ||= RssFeedUrl.find_parent_rss_feed_name(@affiliate, news_item.rss_feed_url_id)
    { title: news_item.title,
      url: news_item.link,
      pub_date: news_item.published_at.to_date.to_s(:db),
      source: source }
  end
end
