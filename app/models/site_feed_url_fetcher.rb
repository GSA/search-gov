class SiteFeedUrlFetcher
  extend Resque::Plugins::Priority
  extend ResqueJobStats

  @queue = :primary

  def self.before_perform_with_timeout(*_args)
    Resque::Plugins::Timeout.timeout = 20.minutes
  end

  def self.perform(site_feed_url_id)
    return unless (site_feed_url = SiteFeedUrl.find_by_id(site_feed_url_id))
    SiteFeedUrlData.new(site_feed_url).import
  end
end
