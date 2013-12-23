module TwitterProfilesHelper
  def legacy_render_tweet_text(tweet, search, index)
    html = highlight_hit(tweet, :tweet_text)
    if tweet.instance.urls.present?
      processed_urls = []
      tweet.instance.urls.each do |entity_url|
        next if processed_urls.include?(entity_url.url)
        processed_urls << entity_url.url
        link = tweet_link_with_click_tracking(entity_url.display_url.html_safe, entity_url.expanded_url, entity_url.url, @affiliate, search, index, @search_vertical)
        html.gsub!(/#{Regexp.escape(entity_url.url)}/, link)
      end
    end
    html
  end

  def tweet_text(tweet, position)
    html = highlight_hit(tweet, :tweet_text)
    if tweet.instance.urls.present?
      processed_urls = []
      tweet.instance.urls.each do |entity_url|
        next if processed_urls.include?(entity_url.url)
        processed_urls << entity_url.url
        link = link_to_tweet_link(tweet, entity_url.display_url.html_safe, entity_url.url, position)
        html.gsub!(/#{Regexp.escape(entity_url.url)}/, link)
      end
    end
    html.html_safe
  end

  def legacy_render_twitter_profile(profile, search, index)
    content = []
    content << profile.name
    content << content_tag(:span, " @#{profile.screen_name}", :class => 'screen-name')
    raw(tweet_link_with_click_tracking(content.join("\n").html_safe, nil, profile.link_to_profile, @affiliate, search, index, @search_vertical))
  end

  def twitter_profile(tweet, position)
    content = []
    profile = tweet.instance.twitter_profile
    content << content_tag(:div, image_tag(profile.profile_image_url, alt: "#{profile.name} avatar"), class: 'profile-image')
    content << content_tag(:span, profile.name, class: 'profile-name')
    content << content_tag(:span, "@#{profile.screen_name}", class: 'profile-screen-name')
    link_to_tweet_link tweet, content.join("\n").html_safe, profile.link_to_profile, position, class: 'profile'
  end

  def link_to_twitter_handle(twitter_profile)
    link_to "@#{twitter_profile.screen_name}",
            "https://twitter.com/#{twitter_profile.screen_name}",
            target: '_blank'
  end

  def twitter_profile_properties(site, twitter_profile)
    if site.affiliate_twitter_settings.
        exists?(twitter_profile_id: twitter_profile.id, show_lists: 1)
      content_tag :span, '(show lists)', class: 'properties'
    end
  end
end
