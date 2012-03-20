module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
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
    when /^(.*)'s mobile search page$/
      search_path(:affiliate => $1, :m => 'true')
    when /^(.*)'s Spanish search page$/
      search_path(:affiliate => $1, :locale => 'es')
    when /^(.*)'s embedded search page$/
      search_path(:affiliate => $1, :embedded => "1")
    when /^(.*)'s oneserp search page$/
      search_path(:affiliate => $1, :oneserp => "1")
      when /^(.*)'s oneserp with strictui search page$/
        search_path(:affiliate => $1, :oneserp => "1", :strictui => "1")
    when /^(.*)'s image search page$/
      image_search_path(:affiliate => $1)
    when /^the news search page$/
      news_search_path
    when /the analytics groups and trends page/
      analytics_groups_trends_path
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
    when /^the (.*)'s admin edit affiliate page$/
      edit_admin_affiliate_path(Affiliate.find_by_name($1))
    when /the admin home page/
      admin_home_page_path
    when /admin site pages page/
      admin_site_pages_path
    when /users admin page/
      admin_users_path
    when /sayt filters admin page/
      admin_sayt_filters_path
    when /the login page/
      login_path
    when /the password reset page/
      password_resets_path
    when /the user account page/
      account_path
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
    when /the Spanish mobile contact form page/
      contact_form_path(:locale => 'es')
    when /the query groups admin page/
      analytics_query_groups_path
    when /the bulk edit query groups page for "([^\"]*)"/
      bulk_edit_analytics_query_group_path(QueryGroup.find_by_name($1))
    when /the boosted contents admin page/
      admin_boosted_contents_path
    when /the affiliate boosted contents admin page/
      admin_affiliate_boosted_contents_path
    when /the top search admin page/
      admin_top_searches_path
    when /the affiliate on-demand urls page for "([^\"]*)"/
      affiliate_on_demand_urls_path(:locale => nil, :m => nil, :affiliate_id => Affiliate.find_by_name($1).id)
    when /the affiliate crawled on-demand urls page for "([^\"]*)"/
      crawled_affiliate_on_demand_urls_path(:locale => nil, :m => nil, :affiliate_id => Affiliate.find_by_name($1).id)
    when /the affiliate uncrawled on-demand urls page for "([^\"]*)"/
      uncrawled_affiliate_on_demand_urls_path(:locale => nil, :m => nil, :affiliate_id => Affiliate.find_by_name($1).id)
    when /the superfresh feed/
      main_superfresh_feed_path
    when /admin sayt suggestions upload/
      new_admin_sayt_suggestions_upload_path
    when /the affiliate admin page with "([^\"]*)" selected$/
      home_affiliates_path(:said => Affiliate.find_by_name($1).id)
    when /the affiliate admin page/
      home_affiliates_path
    when /the "([^\"]*)" affiliate page$/
      affiliate_path(Affiliate.find_by_display_name($1))
    when /the "([^\"]*)" affiliate users page$/
      affiliate_users_path(Affiliate.find_by_display_name($1))
    when /the affiliate sayt page for "([^\"]*)"/
      affiliate_type_ahead_search_index_path(Affiliate.find_by_name($1))
    when /the affiliate sayt demo page for ([^\"]*)/
      demo_affiliate_type_ahead_search_index_path(Affiliate.find_by_name($1))
    when /the (.*)'s featured collections page$/
      affiliate_featured_collections_path(Affiliate.find_by_name($1))
    when /the recalls landing page/
      recalls_path
    when /the recalls search page/
      recalls_search_path
    when /the forms home page/
      forms_path
    when /the top forms admin page$/
      admin_top_forms_path
    when /the top forms admin page for column "([^\"]*)"/
      admin_top_forms_path(:column_number => $1)
    when /the trending searches page/
      trending_searches_widget_path
    when /^(.*)'s trending searches page$/
      trending_searches_widget_path(:aid => Affiliate.find_by_name($1).id)
    when /the affiliate related topics page for "([^\"]*)"/
      affiliate_related_topics_path(Affiliate.find_by_name($1))
    when /the preview affiliate page for "([^\"]*)"/
      preview_affiliate_path(Affiliate.find_by_name($1))
    when /the (.*)'s boosted contents page$/
      affiliate_boosted_contents_path(Affiliate.find_by_name($1))
    when /the new affiliate boosted content page for "([^\"]*)"/
      new_affiliate_boosted_content_path(Affiliate.find_by_name($1))
    when /the edit affiliate boosted content page for "([^\"]*)"/
      edit_affiliate_boosted_content_path(Affiliate.find_by_name($1), Affiliate.find_by_name($1).boosted_contents.first)
    when /the superfresh bulk upload admin page/
      admin_superfresh_urls_bulk_upload_index_path
    when /the 404 page/
      '/aninvalidurl'
    when /the Spanish 404 page/
      '/aninvalidurl?locale=es'
    when /the (.*)'s 404 page$/
      affiliate_page_not_found_path(:name => $1)
    when /the (.*)'s Spanish 404 page$/
      affiliate_page_not_found_path(:name => $1, :locale => 'es')
    when /the (.*)'s staged 404 page$/
      affiliate_page_not_found_path(:name => $1, :staged => 1)
    when /the (.*)'s staged Spanish 404 page$/
      affiliate_page_not_found_path(:name => $1, :locale => 'es', :staged => 1)
    when /the USASearch blog$/
      "http://searchblog.usa.gov/"
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