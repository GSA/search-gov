module TwitterProfilesHelper
  def render_twitter_profile(profile)
    content = []
    content << profile.name
    content << content_tag(:span, " @#{profile.screen_name}", :class => 'screen-name')
    raw(link_to(content.join("\n").html_safe, profile.link_to_profile))
  end
end
