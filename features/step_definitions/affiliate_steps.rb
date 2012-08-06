Given /^the following Affiliates exist:$/ do |table|
  Affiliate.destroy_all
  table.hashes.each do |hash|
    valid_options = {
      :email => hash[:contact_email],
      :password => "random_string",
      :password_confirmation => "random_string",
      :contact_name => hash[:contact_name],
      :phone => "301-123-4567",
      :address => "123 Penn Ave",
      :address2 => "Ste 100",
      :city => "Reston",
      :state => "VA",
      :zip => "20022",
      :organization_name=> "Agency",
      :government_affiliation => "1"
    }
    user = User.find_by_email(hash[:contact_email]) || User.create!( valid_options )
    user.update_attribute(:is_affiliate, true)
    user.update_attribute(:approval_status, 'approved')

    css_properties = ActiveSupport::OrderedHash.new
    Affiliate::DEFAULT_CSS_PROPERTIES.keys.each do |css_property|
      case css_property
        when :show_content_border
          css_properties[css_property] = hash.has_key?('show_content_border') ? (hash[:show_content_border] == 'true' ? '1' : '0') : '1'
        when :show_content_box_shadow
          css_properties[css_property] = hash.has_key?('show_content_box_shadow') ? (hash[:show_content_box_shadow] == 'true' ? '1' : '0') : '1'
        else
          css_properties[css_property] = hash[css_property] unless hash[css_property].blank?
      end
    end

    affiliate = Affiliate.new(
      :display_name => hash[:display_name],
      :header_footer_css => hash[:header_footer_css],
      :header => hash[:header],
      :footer => hash[:footer],
      :staged_header_footer_css => hash[:staged_header_footer_css],
      :staged_header => hash[:staged_header],
      :staged_footer => hash[:staged_footer],
      :is_sayt_enabled => hash[:is_sayt_enabled],
      :search_results_page_title => hash[:search_results_page_title],
      :staged_search_results_page_title => hash[:staged_search_results_page_title],
      :has_staged_content => hash[:has_staged_content] || false,
      :exclude_webtrends => hash[:exclude_webtrends] || false,
      :external_css_url => hash[:external_css_url],
      :staged_external_css_url => hash[:staged_external_css_url],
      :favicon_url => hash[:favicon_url],
      :staged_favicon_url => hash[:staged_favicon_url],
      :theme => hash[:theme],
      :staged_theme => hash[:staged_theme],
      :css_property_hash => css_properties,
      :uses_managed_header_footer => hash[:uses_managed_header_footer],
      :staged_uses_managed_header_footer => hash[:staged_uses_managed_header_footer],
      :managed_header_home_url => hash[:managed_header_home_url],
      :staged_managed_header_home_url => hash[:staged_managed_header_home_url],
      :managed_header_text => hash[:managed_header_text],
      :staged_managed_header_text => hash[:staged_managed_header_text],
      :top_searches_label => hash[:top_searches_label] || 'Search Trends',
      :locale => hash[:locale] || 'en',
      :is_agency_govbox_enabled => hash[:is_agency_govbox_enabled] || false,
      :is_medline_govbox_enabled => hash[:is_medline_govbox_enabled] || false,
      :is_twitter_govbox_enabled => hash[:is_twitter_govbox_enabled] || false,
      :is_photo_govbox_enabled => hash[:is_photo_govbox_enabled] || false,
      :results_source => hash[:results_source] || 'bing+odie',
      :is_related_searches_enabled => hash[:is_related_searches_enabled] || true,
      :ga_web_property_id => hash[:ga_web_property_id],
      :external_tracking_code => hash[:external_tracking_code]
    )
    affiliate.name = hash['name']
    affiliate.save!
    affiliate.users << user
    affiliate.flickr_profiles.create!(:url => hash[:flickr_url], :profile_type => 'user', :profile_id => '1234') if hash[:flickr_url]
    affiliate.facebook_profiles.create!(:username => hash[:facebook_handle]) if hash[:facebook_handle]
    hash[:youtube_handles].split(',').each do |youtube_handle|
      profile = affiliate.youtube_profiles.build(:username => youtube_handle)
      profile.save!(:validate => false)
    end if hash[:youtube_handles]
    affiliate.twitter_profiles.create!(:screen_name => hash[:twitter_handle],
                                       :name => hash[:twitter_handle],
                                       :twitter_id => 1234,
                                       :profile_image_url => 'http://twitter.com/profile.jpg') if hash[:twitter_handle]
    hash[:domains].split(',').each { |domain| affiliate.site_domains.create!(:domain => domain) } unless hash[:domains].blank?
    affiliate.features << Feature.find_or_create_by_internal_name('hosted_sitemaps', :display_name => "Feature Allows them to have Indexed Docs")
  end
end

Given /^the following Misspelling exist:$/ do |table|
  table.hashes.each do |hash|
    Misspelling.create!(:wrong => hash["wrong"], :rite => hash["rite"])
  end
end

Then /^the search bar should have SAYT enabled$/ do
  page.should have_selector("script[type='text/javascript'][src*='/javascripts/sayt-ui.js']")
  page.should have_selector("input[id='search_query'][type='text'][class='usagov-search-autocomplete'][autocomplete='off']")
  page.should have_selector("script[type='text/javascript'][src^='/javascripts/jquery/jquery-ui.custom.min.js']")
end

Then /^the search bar should not have SAYT enabled$/ do
  page.should_not have_selector("script[type='text/javascript'][src*='/javascripts/sayt-ui.js']")
  page.should_not have_selector("input[id='search_query'][type='text'][class='usagov-search-autocomplete'][autocomplete='off']")
  page.should_not have_selector("script[type='text/javascript'][src^='/javascripts/jquery/jquery-ui.custom.min.js']")
end

Then /^the page should have SAYT enabled for (.+)$/ do |affiliate_name|
  page.body.should include(%Q[var usasearch_config = { siteHandle:"#{affiliate_name}" };])
  page.body.should include(%q[script.src = "http://www.example.com/javascripts/remote.loader.js";])
end

Then /^I should see the page with favicon "([^"]*)"$/ do |favicon_url|
  page.should have_selector("link[rel='shortcut icon'][href='#{favicon_url}']")
end

Then /^I should not see the page with favicon "([^"]*)"$/ do |favicon_url|
  page.should_not have_selector("link[rel='shortcut icon'][href='#{favicon_url}']")
end

Then /^I should see the page with affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  page.should have_selector("link[type='text/css'][href*='#{stylesheet_name}']")
end

Then /^I should not see the page with affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  page.should_not have_selector("link[type='text/css'][href*='#{stylesheet_name}']")
end

Then /^I should see the page with external affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  page.should have_selector("link[type='text/css'][href='#{stylesheet_name}']")
end

Then /^I should not see the page with external affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  page.should_not have_selector("link[type='text/css'][href='#{stylesheet_name}']")
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be enabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  page.body.should match("aid=#{affiliate.id}")
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  page.body.should_not match("aid=#{affiliate.id}")
end

Then /^the "([^\"]*)" button should be checked$/ do |field|
  page.should have_selector "input[type='radio'][checked='checked'][id='#{field}']"
end

Then /I should see the API key/ do
  page.should have_selector(".content-box", :text => "Your API Key:")
end

Then /^(.+) for site named "([^\"]*)"$/ do |step, site_display_name|
  site = Affiliate.find_by_display_name site_display_name
  %{#{step} within "tr#site_#{site.id}"}
end

Then /^I should see sorted sites in the site dropdown list$/ do
  sites = @current_user.affiliates.sort{|x,y| x.display_name <=> y.display_name}
  sites.each_with_index do |site, index|
    page.should have_selector("#affiliate_id option:nth-child(#{index + 1})", :value => site.id)
  end
end

Then /^I should see sorted sites in the site list$/ do
  sites = @current_user.affiliates.sort{|x,y| x.display_name <=> y.display_name}
  sites.each_with_index do |site, index|
    page.should have_selector(".generic-table tbody tr:nth-child(#{index + 1}) td.site-name a", :text => site.display_name)
  end
end

Then /^I should see "([^\"]*)" in the site wizards header$/ do |step|
  page.should have_selector(".steps_header img[alt='#{step}']")
end

Given /^the following DailySearchModuleStats exist for each day in yesterday's month$/ do |table|
  end_date = Date.yesterday
  start_date = end_date.beginning_of_month
  table.hashes.each do |hash|
    start_date.upto(end_date) do |day|
      DailySearchModuleStat.create!(:day => day, :affiliate_name => hash['affiliate'], :locale => 'en', :vertical => 'web',
                                    :module_tag => 'BWEB', :clicks => hash['total_clicks'], :impressions => hash['total_clicks'])
    end
  end
end

Given /^the following DailySearchModuleStats exist for each day in "([^\"]*)"$/ do |month_year, table|
  start_date = Date.parse(month_year + "-01")
  end_date = start_date.end_of_month
  table.hashes.each do |hash|
    start_date.upto(end_date) do |day|
      DailySearchModuleStat.create!(:day => day, :affiliate_name => hash['affiliate'], :locale => 'en', :vertical => 'web',
                                    :module_tag => 'BWEB', :clicks => hash['total_clicks'], :impressions => hash['total_clicks'])
    end
  end
end

Then /^I should see the page with Webtrends tag$/ do
  page.should have_selector("script[src*='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
end

Then /^I should not see the page with Webtrends tag$/ do
  page.should_not have_selector("script[src*='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
end

Then /^I should see the code for (English|Spanish) language sites$/ do |locale|
  locales = { 'English' => 'en', 'Spanish' => 'es' }
  page.should have_selector("#embed_code_textarea_#{locales[locale]}")
end

Then /^I should see the affiliate custom css$/ do
  page.should have_selector("head style")
end

Then /^I should see some Bing search results$/ do
  page.should have_selector("#results > .searchresult")
end

Then /^the "([^"]*)" theme should be selected$/ do |theme|
  field_labeled(theme)['checked'].should be_true
end

Then /^the "([^"]*)" field should be disabled$/ do |label|
  field_labeled(label)['disabled'].should == 'disabled'
end

Then /^the "Custom" theme should be visible$/ do
  page.should_not have_selector(".hidden-custom-theme")
end

Then /^the "Custom" theme should not be visible$/ do
  page.should have_selector(".hidden-custom-theme")
end

Then /^I should see the page with internal CSS "([^"]*)"$/ do |css|
  page.body.should match(css)
end

Then /^I should see the page with content border$/ do
  page.should have_selector('body.with-content-border')
end

Then /^I should not see the page with content border$/ do
  page.should_not have_selector('body.with-content-border')
end

Then /^I should see the page with content box shadow$/ do
  page.should have_selector('body.with-content-box-shadow')
end

Then /^I should not see the page with content box shadow$/ do
  page.should_not have_selector('body.with-content-box-shadow')
end

Then /^I should see "([^"]*)" image$/ do |image_file_name|
  page.should have_selector("img[src*='#{image_file_name}']")
end

Then /^I should not see "([^"]*)" image$/ do |image_file_name|
  page.should_not have_selector("img[src*='#{image_file_name}']")
end

Then /^I should not see the SERP header$/ do
  page.should_not have_selector('#header')
end

Then /^I should not see tainted SERP (header|footer)$/ do |section|
  Affiliate::BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.each do |element|
    page.should_not have_selector("##{section} #{element}")
  end
end

Given /^the following Connections exist for the affiliate "([^"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |hash|
    connected_affiliate = Affiliate.find_by_name(hash[:connected_affiliate])
    affiliate.connections.create!(:connected_affiliate => connected_affiliate, :display_name => hash[:display_name])
  end
end

Then /^the "([^"]*)" field should contain site ID for (.+)$/ do |label, affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  step %{the "#{label}" field should contain "#{affiliate.id}"}
end
