class NavigableNameUpdater
  EN_ES = %w(en es)

  def initialize(except: EN_ES)
    @locales = Language.pluck(:code) - except
  end

  def update
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

  # Image search functionality removed
end
