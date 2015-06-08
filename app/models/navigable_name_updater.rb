class NavigableNameUpdater
  EN_ES = %w(en es)

  def initialize(except: EN_ES)
    @locales = Language.pluck(:code) - except
  end

  def update
    update_image_search_label
    update_video_search_label
  end

  private

  def update_video_search_label
    Affiliate.where(locale: @locales).each do |affiliate|
      affiliate.rss_feeds.managed.each do |rss_feed|
        Rails.logger.info("Updating RssFeed #{rss_feed.id} name from #{rss_feed.name}")
        rss_feed.update_attribute(:name, I18n.t(:videos, locale: affiliate.locale))
        Rails.logger.info("...Updated RssFeed #{rss_feed.id} name to #{rss_feed.name}")
      end
    end
  end

  def update_image_search_label
    ImageSearchLabel.joins(:affiliate).where(affiliates: { locale: @locales }).readonly(false).each do |image_search_label|
      Rails.logger.info("Updating ImageSearchLabel #{image_search_label.id} name from #{image_search_label.name}")
      image_search_label.name = nil
      image_search_label.save!
      Rails.logger.info("...Updated ImageSearchLabel #{image_search_label.id} name to #{image_search_label.name}")
    end
  end
end
