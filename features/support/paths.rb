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
    when /^(.*)'s search page$/
      search_path(:affiliate => $1)
    when /^(.*)'s mobile search page$/
      search_path(:affiliate => $1, :m => 'true')
    when /^(.*)'s strictui search page$/
      search_path(:affiliate => $1, :strictui => "1")
    when /^(.*)'s search page with unsanitized "([^\"]*)" query$/
      search_path(:affiliate => $1, :query => "<script>#{$2}</script>")
    when /^(.*)'s search page with site limited to "([^\"]*)"$/
      search_path(:affiliate => $1, :sitelimit => $2)
    when /^(.*)'s image search page$/
      image_search_path(:affiliate => $1)
    when /^(.*)'s news search page$/
      news_search_path(:affiliate => $1)
    when /^(.*)'s "([^\"]*)" news search page$/
      news_search_path(:affiliate => $1, :channel => Affiliate.find_by_name($1).rss_feeds.find_by_name($2))
    when /^(.*)'s docs search page$/
      docs_search_path(:affiliate => $1)
    when /^(.*)'s "([^\"]*)" docs search page$/
      docs_search_path(:affiliate => $1, :dc => Affiliate.find_by_name($1).document_collections.find_by_name($2))
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
    when /the query groups admin page/
      analytics_query_groups_path
    when /the boosted contents admin page/
      admin_boosted_contents_path
    when /the affiliate boosted contents admin page/
      admin_affiliate_boosted_contents_path
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
    when /the affiliate sayt demo ([[:digit:]]) page for ([^\"]*)/
      demo_affiliate_type_ahead_search_index_path(Affiliate.find_by_name($2), :page => $1)
    when /the (.*)'s featured collections page$/
      affiliate_featured_collections_path(Affiliate.find_by_name($1))
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
    when /^(.*)'s new (facebook|flickr|twitter|youtube) profile page$/
      affiliate_social_media_path(Affiliate.find_by_name($1), :profile_type => "#{$2.camelize}Profile")
    when /^the (.*)'s Dashboard page$/
      site_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Manage Content page$/
      site_content_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Manage Display page$/
      edit_site_display_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Font & Color page$/
      edit_site_font_and_color_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Image Assets page$/
      edit_site_image_assets_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Advanced Display page$/
      edit_site_advanced_display_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Activate Search page$/
      site_embed_code_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Analytics page$/
      new_site_raw_logs_access_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Filter URLs page$/
      site_filter_urls_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Supplemental URLs page$/
      site_supplemental_urls_path(Affiliate.find_by_name($1))
    when /^the sites page$/
      sites_path
    when /^the new site page$/
      new_site_path
    when /the 404 page/
      '/aninvalidurl'
    when /the Spanish 404 page/
      '/aninvalidurl?locale=es'
    when /the (.*)'s 404 page$/
      affiliate_page_not_found_path(:name => $1)
    when /the (.*)'s staged 404 page$/
      affiliate_page_not_found_path(:name => $1, :staged => 1)
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
