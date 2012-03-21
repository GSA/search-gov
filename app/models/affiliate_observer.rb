class AffiliateObserver < ActiveRecord::Observer
  observe :affiliate

  def after_create(affiliate)
    unless affiliate.youtube_handle.blank?
      affiliate.rss_feeds.create!(:name => 'Videos', :is_managed => true, :url => generate_youtube_url(affiliate.youtube_handle))
    end
  end

  def after_update(affiliate)
    if affiliate.youtube_handle.blank?
      affiliate.rss_feeds.managed.videos.destroy_all
    else
      managed_video_rss_feed = affiliate.rss_feeds.managed.videos.first
      youtube_url = generate_youtube_url(affiliate.youtube_handle)

      if managed_video_rss_feed.blank?
        affiliate.rss_feeds.create!(:name => 'Videos', :is_managed => true, :url => youtube_url)
      else
        managed_video_rss_feed.update_attributes!(:url => youtube_url)
      end
    end
  end

  private
  def generate_youtube_url(youtube_handle)
    url_params = ActiveSupport::OrderedHash.new
    url_params[:alt] = 'rss'
    url_params[:author] = "#{youtube_handle}"
    "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
  end
end
