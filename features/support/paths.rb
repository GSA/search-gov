module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the homepage/
      root_path
    when /the search page/
      search_path
    when /^(.*)'s search page$/
      search_path(:affiliate => $1)
    when /the analytics query search results page/
      analytics_query_search_path
    when /the FAQ page/
      analytics_faq_path
    when /the analytics homepage/
      analytics_home_page_path
    when /the timeline page for "([^\"]*)"$/
      query_timeline_path($1)
    when /the affiliate admin home page/
      admin_affiliates_path
    when /the spotlights admin homepage/
      admin_spotlights_path
    when /the affiliate admin broadcast page/
      new_admin_affiliate_broadcast_path
    when /the login page/
      new_user_session_path
    when /the password reset page/
      password_resets_path
    when /the user account page/
      account_path
    when /the new user page/
      new_account_path
    when /the affiliate welcome page/
      affiliates_path

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
