class AffiliateObserver < ActiveRecord::Observer
  observe :affiliate

  def after_create(affiliate)
    unless affiliate.youtube_handle.blank?
      create_video_rss_feed(affiliate, generate_youtube_url(affiliate.youtube_handle))
    end
  end

  def after_update(affiliate)
    if affiliate.youtube_handle.blank?
      affiliate.rss_feeds.managed.videos.destroy_all
    else
      managed_video_rss_feed = affiliate.rss_feeds.managed.videos.first
      youtube_url = generate_youtube_url(affiliate.youtube_handle)

      if managed_video_rss_feed.blank?
        create_video_rss_feed(affiliate, youtube_url)
      elsif managed_video_rss_feed.rss_feed_urls.first.url != youtube_url
        managed_video_rss_feed.rss_feed_urls.destroy_all
        managed_video_rss_feed.rss_feed_urls.build(:url => youtube_url)
        managed_video_rss_feed.save!
      end
    end
  end

  private
  def generate_youtube_url(youtube_handle)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = "#{youtube_handle}"
    url_params[:orderby] = 'published'
    "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
  end

  def create_video_rss_feed(affiliate, url)
    rss_feed = affiliate.rss_feeds.build(:name => 'Videos')
    rss_feed.is_managed = true
    rss_feed.rss_feed_urls.build(:url => url)
    rss_feed.save!
  end
end
