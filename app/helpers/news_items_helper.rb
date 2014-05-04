module NewsItemsHelper
  def unique_news_items(news_items)
    news_items.uniq { |n| n.link }
  end

  def news_item_partial(news_item)
    news_item.is_video? ? 'searches/video_news_result' : 'searches/news_result'
  end

  def news_item_time_ago_in_words(published_at, separator = '')
    if published_at < Time.current
      [time_ago_in_words(published_at), separator].join
    end
  end
end
