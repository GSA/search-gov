class AffiliateObserver < ActiveRecord::Observer
  observe :affiliate

  def after_create(affiliate)
    image_search_label = affiliate.build_image_search_label
    image_search_label.save!

    unless affiliate.youtube_handles.blank?
      youtube_handles = generate_youtube_urls affiliate.youtube_handles
      create_video_rss_feed(affiliate, youtube_handles)
    end
  end

  def after_update(affiliate)
    if affiliate.youtube_handles.blank?
      affiliate.rss_feeds.managed.videos.destroy_all
    else
      rss_feed = affiliate.rss_feeds.managed.videos.first
      target_urls = generate_youtube_urls(affiliate.youtube_handles)

      if rss_feed.blank?
        create_video_rss_feed(affiliate, target_urls)
      else
        rss_feed.rss_feed_urls.reject(&:is_playlist?).each do |existing_rss_feed_url|
          if target_urls.include?(existing_rss_feed_url.url)
            target_urls.delete(existing_rss_feed_url.url)
          else
            existing_rss_feed_url.destroy
          end
        end
        target_urls.each { |url| rss_feed.rss_feed_urls.build(:url => url) }
        rss_feed.save!
      end
    end
  end

  private
  def generate_youtube_urls(youtube_handles)
    youtube_handles.collect do |youtube_handle|
      url_params = ActiveSupport::OrderedHash.new
      url_params[:alt] = 'rss'
      url_params[:author] = "#{youtube_handle}"
      url_params[:orderby] = 'published'
      "http://gdata.youtube.com/feeds/base/videos?#{url_params.to_param}".downcase
    end
  end

  def create_video_rss_feed(affiliate, urls)
    rss_feed = affiliate.rss_feeds.build(:name => 'Videos')
    rss_feed.is_managed = true
    urls.each { |url| rss_feed.rss_feed_urls.build(:url => url) }
    rss_feed.save!
  end
end
