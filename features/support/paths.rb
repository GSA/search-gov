module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the search page/
      search_path
    when /^(.*)'s search page$/
      search_path(:affiliate => $1)
    when /^(.*)'s advanced search page$/
      advanced_search_path(:affiliate => $1)
    when /^(.*)'s search page with unsanitized "([^\"]*)" query$/
      search_path(:affiliate => $1, :query => "<b>#{$2}</b><script>script</script>")
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
    when /^the (.*)'s admin edit affiliate page$/
      edit_admin_affiliate_path(Affiliate.find_by_name($1))
    when /the admin home page/
      admin_home_page_path
    when /admin sites page/
      admin_affiliates_path
    when /users admin page/
      admin_users_path
    when /sayt filters admin page/
      admin_sayt_filters_path
    when /the login page/
      login_path
    when /the sign up page/
      signup_path
    when /the user account page/
      account_path
    when /the user edit account page/
      edit_account_path
    when /the reports homepage/
      monthly_reports_path
    when /the affiliate analytics query search results page/
      query_search_affiliate_analytics_path
    when /the boosted contents admin page/
      admin_boosted_contents_path
    when /the affiliate admin page with "([^\"]*)" selected$/
      sites_path(:said => Affiliate.find_by_name($1).id)
    when /the affiliate admin page/
      sites_path
    when /the "([^\"]*)" affiliate page$/
      site_path(Affiliate.find_by_display_name($1))
    when /the "([^\"]*)" affiliate users page$/
      affiliate_users_path(Affiliate.find_by_display_name($1))
    when /the (.*)'s featured collections page$/
      affiliate_featured_collections_path(Affiliate.find_by_name($1))
    when /the (.*)'s boosted contents page$/
      affiliate_boosted_contents_path(Affiliate.find_by_name($1))
    when /the new affiliate boosted content page for "([^\"]*)"/
      new_affiliate_boosted_content_path(Affiliate.find_by_name($1))
    when /the edit affiliate boosted content page for "([^\"]*)"/
      edit_affiliate_boosted_content_path(Affiliate.find_by_name($1), Affiliate.find_by_name($1).boosted_contents.first)
    when /the superfresh bulk upload admin page/
      admin_superfresh_urls_bulk_upload_index_path
    when /the bulk url upload admin page/
      admin_bulk_url_upload_index_path
    when /^(.*)'s new (flickr|twitter|youtube) profile page$/
      affiliate_social_media_path(Affiliate.find_by_name($1), :profile_type => "#{$2.camelize}Profile")
    when /^the (.*)'s Dashboard page$/
      site_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Manage Content page$/
      site_content_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Manage Display page$/
      edit_site_display_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Font & Colors page$/
      edit_site_font_and_colors_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Image Assets page$/
      edit_site_image_assets_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Header & Footer page$/
      edit_site_header_and_footer_path(Affiliate.find_by_name($1))
    when /^the (.*)'s No Results Page page$/
      edit_site_no_results_pages_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Activate Search page$/
      site_embed_code_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Best Bets Graphics page$/
      site_best_bets_graphics_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Best Bets Texts page$/
      site_best_bets_texts_path(Affiliate.find_by_name($1))
    when /^the (.*)'s "([^\"]*)" RSS feed page$/
      site_rss_feed_path(Affiliate.find_by_name($1), Affiliate.find_by_name($1).rss_feeds.find_by_name($2))
    when /^the (.*)'s Analytics page$/
      new_site_queries_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Filter URLs page$/
      site_filter_urls_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Filter Tags page$/
      site_tag_filters_path(Affiliate.find_by_name($1))
    when /^the (.*)'s Supplemental URLs page$/
      site_supplemental_urls_path(Affiliate.find_by_name($1))
    when /^the sites page$/
      sites_path
    when /^the new site page$/
      new_site_path
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
