module NewsItemsHelper
  def unique_news_items(news_items)
    news_items.uniq { |n| n.link }
  end

  def news_item_time_ago_in_words(published_at)
    time_ago_in_words(published_at) if published_at < Time.current
  end
end
