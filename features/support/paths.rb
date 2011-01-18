module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the homepage/
      root_path
    when /the Spanish homepage/
      root_path(:locale => 'es')
    when /the search page/
      search_path
    when /the Spanish mobile search results page for "([^\"]*)"$/
      search_path(:query => $1, :locale => 'en', :m => 'true')
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
    when /admin site pages page/
      admin_site_pages_path
    when /users admin page/
      admin_users_path
    when /sayt filters admin page/
      admin_sayt_filters_path
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
      query_search_affiliate_analytics_path
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
    when /the affiliate boosted sites admin page/
      admin_affiliate_boosted_sites_path
    when /the top search admin page/
      admin_top_searches_path
    when /the affiliate superfresh page/
      affiliate_superfresh_urls_path(:locale => nil, :m => nil)
    when /the superfresh feed/
      main_superfresh_feed_path
    when /admin sayt suggestions upload/
      new_admin_sayt_suggestions_upload_path
    when /the developers home page/
      developers_path
    when /the developers signup page/
      developers_path
    when /the affiliate admin page with "([^\"]*)" selected$/
      home_affiliates_path(:said => Affiliate.find_by_name($1).id)
    when /the affiliate admin page/
      home_affiliates_path
    when /the affiliate sayt page/
      affiliate_type_ahead_search_index_path(:locale => nil, :m => nil)
    when /the recalls search page/
      recalls_search_path
    when /the program welcome page/
      program_path(:locale => nil, :m => nil)
    when /the api page/
      api_docs_path(:locale => nil, :m => nil)
    when /the recalls api page/
      recalls_api_docs_path(:locale => nil, :m => nil)
    when /the terms of service page/
      recalls_tos_docs_path(:locale => nil, :m => nil) 
    when /the searchusagov page/
      searchusagov_path(:locale => nil, :m => nil)
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
