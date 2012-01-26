Given /^the following Affiliates exist:$/ do |table|
  table.hashes.each do |hash|
    valid_options = {
      :email => hash["contact_email"],
      :password => "random_string",
      :password_confirmation => "random_string",
      :contact_name => hash["contact_name"],
      :phone => "301-123-4567",
      :address => "123 Penn Ave",
      :address2 => "Ste 100",
      :city => "Reston",
      :state => "VA",
      :zip => "20022",
      :organization_name=> "Agency",
      :government_affiliation => "1"
    }
    user = User.find_by_email(hash["contact_email"]) || User.create!( valid_options )
    user.update_attribute(:is_affiliate, true)
    user.update_attribute(:approval_status, 'approved')

    default_affiliate_template = AffiliateTemplate.find_by_stylesheet("default")

    uses_one_serp = (hash[:uses_one_serp].blank? or hash[:uses_one_serp] == 'true') ? true : false
    if uses_one_serp
      affiliate_template = nil
      staged_affiliate_template = nil
      theme = hash[:theme] || 'custom'
      staged_theme = hash[:theme] || 'custom'
    else
      affiliate_template = hash["affiliate_template_name"].blank? ? default_affiliate_template : AffiliateTemplate.find_by_name(hash["affiliate_template_name"])
      staged_affiliate_template = hash["staged_affiliate_template_name"].blank? ? default_affiliate_template : AffiliateTemplate.find_by_name(hash["staged_affiliate_template_name"])
      theme = nil
      staged_theme = nil
    end

    css_properties = ActiveSupport::OrderedHash.new
    Affiliate::DEFAULT_CSS_PROPERTIES.keys.each do |css_property|
      css_properties[css_property] = hash[css_property] unless hash[css_property].blank?
    end

    affiliate = Affiliate.new(
      :display_name => hash["display_name"],
      :name => hash["name"],
      :affiliate_template_id => affiliate_template.nil? ? nil : affiliate_template.id,
      :header_footer_css => hash["header_footer_css"],
      :header => hash["header"],
      :footer => hash["footer"],
      :staged_affiliate_template_id => staged_affiliate_template.nil? ? nil : staged_affiliate_template.id,
      :staged_header_footer_css => hash["staged_header_footer_css"],
      :staged_header => hash["staged_header"],
      :staged_footer => hash["staged_footer"],
      :is_sayt_enabled => hash["is_sayt_enabled"],
      :search_results_page_title => hash["search_results_page_title"],
      :staged_search_results_page_title => hash["staged_search_results_page_title"],
      :has_staged_content => hash["has_staged_content"] || false,
      :exclude_webtrends => hash["exclude_webtrends"] || false,
      :is_popular_links_enabled => hash["is_popular_links_enabled"] || true,
      :external_css_url => hash["external_css_url"],
      :staged_external_css_url => hash["staged_external_css_url"],
      :favicon_url => hash["favicon_url"],
      :staged_favicon_url => hash["staged_favicon_url"],
      :facebook_handle => hash["facebook_handle"],
      :flickr_url => hash["flickr_url"],
      :twitter_handle => hash["twitter_handle"],
      :youtube_handle => hash["youtube_handle"],
      :theme => theme,
      :staged_theme => staged_theme,
      :css_properties => css_properties.to_json,
      :top_searches_label => hash["top_searches_label"] || 'Search Trends',
      :locale => hash["locale"] || 'en',
      :is_agency_govbox_enabled => hash["is_agency_govbox_enabled"] || false,
      :is_medline_govbox_enabled => hash["is_medline_govbox_enabled"] || false,
      :results_source => hash["results_source"] || "bing"
    )
    affiliate.uses_one_serp = uses_one_serp
    affiliate.save!
    affiliate.users << user

    hash[:domains].split(',').each { |domain| affiliate.site_domains.create!(:domain => domain) } unless hash[:domains].blank?
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

Then /^the affiliate search bar should have SAYT enabled$/ do
  page.should have_selector("script[type='text/javascript'][src*='/javascripts/sayt.js']")
  page.should have_selector("input[type='text'][class='usagov-search-autocomplete'][autocomplete='off']")
  page.should have_selector("script[type='text/javascript'][src^='/javascripts/jquery/jquery.min.js']")
  page.should have_selector("script[type='text/javascript'][src^='/javascripts/jquery/jquery.bgiframe.min.js']")
  page.should have_selector("script[type='text/javascript'][src^='/javascripts/sayt.js']")
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

Then /^the affiliate "([^\"]*)" should be set to use global related topics$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.related_topics_setting.should == 'global_enabled'
end

Then /I should see the API key/ do
  page.should have_selector(".content-box", :text => "Your API Key:")
end

Then /I should see the TOS link/ do
  page.should have_selector(".admin-content p.tos-centered a", :text => "Terms of Service")
end

Then /I should not see the TOS link/ do
  page.should_not have_selector(".admin-content p.tos-centered a", :text => "Terms of Service")
end

Then /^the affiliate "([^\"]*)" should be set to use affiliate related topics$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.related_topics_setting.should == 'affiliate_enabled'
end

Then /^the affiliate "([^\"]*)" related topics should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.related_topics_setting.should == 'disabled'
end

Then /^the "([^\"]*)" template should be selected$/ do |template_name|
  actual_template_id =  field_labeled(template_name).value
  affiliate_template = AffiliateTemplate.find(actual_template_id)
  affiliate_template.name.should == template_name
end

Then /^(.+) for site named "([^"]*)"$/ do |step, site_display_name|
  site = Affiliate.find_by_display_name site_display_name
  Then %{#{step} within "tr#site_#{site.id}"}
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

Given /^the following popular URLs exist:$/ do |table|
  table.hashes.each do |hash|
    affiliate = Affiliate.find_by_name hash['affiliate_name']
    PopularUrl.create!(:affiliate => affiliate,
                                :title => hash['title'],
                                :url => hash['url'],
                                :rank => hash['rank'])
  end
end

Then /^I should see (\d+) popular URLs$/ do |count|
  page.should have_selector("#popular_urls ul>li>a", :count => count)
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

Then /^I should see the stats code$/ do
  page.should have_selector("#embed_stats_code_textarea")
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

Then /^I should see "([^"]*)" as a header$/ do |header|
  page.should have_selector("#default-header", :text => header)
end

Then /^I should not see "([^"]*)" as a header$/ do |header|
  page.should_not have_selector("#default-header", :text => header)
end