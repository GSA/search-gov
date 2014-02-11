class ElasticNewsItemData

  def initialize(news_item)
    @news_item = news_item
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@news_item, :id, :rss_feed_url_id, :title, :description, :link, :contributor, :subject, :publisher, :tags)
      json.published_at @news_item.published_at.strftime("%Y-%m-%dT%H:%M:%S")
      json.language "#{@news_item.language}_analyzer"
    end
  end

end