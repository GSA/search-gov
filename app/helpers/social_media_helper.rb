module SocialMediaHelper
  def render_social_media_table_row(affiliate, profile)
    return if profile.new_record?
    first_column = content_tag(:td, profile.class.name.split("Profile").first)
    profile_column = :username if profile.is_a?(FacebookProfile) or profile.is_a?(YoutubeProfile)
    profile_column = :url if profile.is_a?(FlickrProfile)
    profile_column = :screen_name if profile.is_a?(TwitterProfile)
    second_column = content_tag(:td, link_to(profile.send(profile_column), profile.link_to_profile, :target => "_blank"))
    preview_link = link_to('Recent Content', preview_affiliate_social_medium_path(:affiliate_id => affiliate.id, :id => profile.id, :profile_type => profile.class.name)) unless profile.is_a?(FacebookProfile)
    delete_link = link_to('Delete', affiliate_social_medium_path(:affiliate_id => affiliate.id, :id => profile.id, :profile_type => profile.class.name), :method => :delete)
    third_column = content_tag(:td, [preview_link, delete_link].join(" ").html_safe, :class => 'actions').html_safe
    content_tag(:tr, [first_column, second_column, third_column].join("\n").html_safe)
  end

  def render_social_media_preview(recent_social_media)
    content = []
    recent_social_media.each do |social_media|
      if social_media.is_a?(NewsItem)
        content << render_news_item_preview(social_media)
      elsif social_media.is_a?(Tweet)
        content << render_tweet_preview(social_media)
      elsif social_media.is_a?(FlickrPhoto)
        content << render_flickr_photo_preview(social_media)
      end
    end
    content_tag :div, content.join("\n").html_safe
  end

  def render_news_item_preview(news_item)
    content = []
    content << content_tag(:div, image_tag(youtube_thumbnail_url(news_item)))
    content << content_tag(:div, "#{link_to(news_item.title, news_item.link)} - #{time_ago_in_words(news_item.published_at)}".html_safe)
    content_tag :div, content.join("\n").html_safe, :class => 'preview', :style => 'margin-bottom: 10px;'
  end

  def render_tweet_preview(tweet)
    content = []
    content << content_tag(:div, tweet.tweet_text)
    content << content_tag(:div, link_to(time_ago_in_words(tweet.published_at), tweet.link_to_tweet))
    content_tag :div, content.join("\n").html_safe, :class => 'preview', :style => 'margin-bottom: 10px;'
  end

  def render_flickr_photo_preview(flickr_photo)
    content = []
    content << image_tag(flickr_photo.url_sq)
    content << content_tag(:div, "#{link_to(flickr_photo.title, flickr_photo.flickr_url)} - #{time_ago_in_words(flickr_photo.date_taken)}".html_safe)
    content_tag :div, content.join("\n").html_safe, :class => 'preview', :style => 'margin-bottom: 10px;'
  end
end
