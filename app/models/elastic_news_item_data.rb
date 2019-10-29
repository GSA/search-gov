class ElasticNewsItemData
  DAYS_BACK = 7

  def initialize(news_item)
    @news_item = news_item
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@news_item, :id, :rss_feed_url_id, :title, :description, :body, :link, :tags)
      ElasticNewsItem::DUBLIN_CORE_AGG_NAMES.each do |dublin_core_field|
        json.set! dublin_core_field, @news_item.send(dublin_core_field).split(',').map(&:squish) if @news_item.send(dublin_core_field).present?
      end
      json.published_at @news_item.published_at.strftime("%Y-%m-%dT%H:%M:%S")
      json.popularity LinkPopularity.popularity_for(@news_item.link, DAYS_BACK)
      json.language "#{@news_item.language}_analyzer"
    end
  end

end
