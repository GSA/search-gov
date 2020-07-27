class RssFeedUrlObserver < ActiveRecord::Observer
  def after_create(rss_feed_url)
    Resque.enqueue_with_priority(:high, OasisMrssNotification, rss_feed_url.id)
  end
end
