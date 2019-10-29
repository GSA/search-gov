# frozen_string_literal: true

class ElasticNewsItemData
  DAYS_BACK = 7

  attr_reader :news_item, :language

  def initialize(news_item)
    @news_item = news_item
    @language = news_item.owner_language_guess
  end

  def to_builder
    Jbuilder.new do |json|
      json.(news_item, :id, :rss_feed_url_id, :link, :tags)
      dublin_core_values(json)
      %w[title description body].each do |field|
        json.set! "#{field}.#{language}", news_item.send(field)
      end
      json.published_at news_item.published_at.strftime('%Y-%m-%dT%H:%M:%S')
      json.popularity popularity
      json.language language
    end
  end

  private

  def dublin_core_values(json)
    ElasticNewsItem::DUBLIN_CORE_AGG_NAMES.each do |dublin_core_field|
      if news_item.send(dublin_core_field).present?
        value = news_item.send(dublin_core_field).split(',').map(&:squish)
        json.set! dublin_core_field, value
      end
    end
  end

  def popularity
    LinkPopularity.popularity_for(news_item.link, DAYS_BACK)
  end
end
