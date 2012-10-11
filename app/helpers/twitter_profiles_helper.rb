module TwitterProfilesHelper
  def render_tweet_text(tweet, search, index)
    tweet_text = highlight_hit(tweet, :tweet_text)
    if tweet.instance.urls.present?
      processed_urls = []
      tweet.instance.urls.each do |entity_url|
        next if processed_urls.include?(entity_url.url)
        processed_urls << entity_url.url
        link = tweet_link_with_click_tracking(entity_url.display_url.html_safe, entity_url.expanded_url, entity_url.url, @affiliate, search, index, @search_vertical)
        tweet_text.gsub!(/#{Regexp.escape(entity_url.url)}/, link)
      end
    end
    tweet_text
  end

  def render_twitter_profile(profile, search, index)
    content = []
    content << profile.name
    content << content_tag(:span, " @#{profile.screen_name}", :class => 'screen-name')
    raw(tweet_link_with_click_tracking(content.join("\n").html_safe, nil, profile.link_to_profile, @affiliate, search, index, @search_vertical))
  end
end
