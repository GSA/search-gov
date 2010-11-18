module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the homepage/
      root_path
    when /the search page/
      search_path
    when /the advanced search page/
      advanced_search_path
    when /the image search page/
      image_search_path
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
    when /the admin home page/
      admin_home_page_path
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
    when /the reports homepage/
      monthly_reports_path
    when /the affiliate analytics query search results page/
      affiliate_analytics_query_search_path
    when /the top queries csv report/
      top_queries_path
    when /the daily top queries csv report/
      daily_top_queries_path
    when /the affiliate advanced search page for "([^\"]*)"$/
      advanced_search_path(:affiliate => $1)
    when /the mobile contact form page/
      contact_form_path
    when /the query groups admin page/
      analytics_query_groups_path
    when /the bulk edit query groups page/
      bulk_edit_analytics_query_group_path
    when /the boosted sites admin page/
      admin_boosted_sites_path
    when /the top search admin page/
      admin_top_searches_path
    when /the affiliate superfresh page/
      superfresh_urls_affiliate_path(:locale => nil, :m => nil)
    when /the superfresh feed/
      superfresh_feed_path
    when /the developers home page/
      developers_path
    when /the developers signup page/
      developers_path
    when /the affiliate admin page with "([^\"]*)" selected$/
      home_affiliates_path(:said => Affiliate.find_by_name($1).id)
    when /the affiliate admin page/
      home_affiliates_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
