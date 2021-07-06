module TwitterProfilesHelper
  def tweet_text(tweet, position)
    inject_tweet_links(tweet) do |entity_url|
      link_to_tweet_link(tweet, entity_url.display_url.html_safe, entity_url.url, position, url: entity_url.expanded_url)
    end
  end

  def inject_tweet_links(tweet)
    html = tweet.tweet_text
    if tweet.urls.present?
      processed_urls = []
      tweet.urls.each do |entity_url|
        next if processed_urls.include?(entity_url.url)
        processed_urls << entity_url.url
        link = yield entity_url
        html.gsub!(/#{Regexp.escape(entity_url.url)}/, link)
      end
    end
    html.html_safe
  end

  def twitter_profile(tweet, position)
    content = []
    profile = tweet.twitter_profile
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
