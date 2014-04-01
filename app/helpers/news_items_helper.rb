module NewsItemsHelper
  def unique_news_items(news_items)
    news_items.uniq { |n| n.link }
  end
end
