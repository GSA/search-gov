Given /^the following( legacy| search consumer| SearchGov)? Affiliates exist:$/ do |affiliate_type, table|
  Affiliate.destroy_all
  table.hashes.each do |hash|
    valid_options = {
        email: hash[:contact_email],
        contact_name: hash[:contact_name],
        organization_name: 'Agency'
    }
    user = User.find_by_email(hash[:contact_email]) || User.create!( valid_options)
    user.update_attribute(:is_affiliate, true)
    user.update_attribute(:approval_status, 'approved')

    excluded_keys = %w(agency_abbreviation contact_email contact_name domains youtube_handles is_image_search_navigable)
    affiliate_attributes = hash.except *excluded_keys
    affiliate_attributes['force_mobile_format'] ||= (affiliate_type !~ /legacy/)
    affiliate_attributes['search_consumer_search_enabled'] ||= (/search consumer/ === affiliate_type)
    affiliate_attributes['search_engine'] = 'SearchGov' if (/SearchGov/ === affiliate_type)
    affiliate = Affiliate.create! affiliate_attributes
    affiliate.image_search_label.navigation.update_attributes!(is_active: true) if hash[:is_image_search_navigable] == 'true'
    affiliate.users << user

    if hash[:agency_abbreviation].present?
      agency = Agency.find_by_abbreviation hash[:agency_abbreviation]
      affiliate.update_attributes!(agency: agency)
    end

    hash[:youtube_handles].split(',').each do |youtube_handle|
      profile = YoutubeProfile.where(channel_id: "#{youtube_handle}_channel_id",
                                     title: youtube_handle).first_or_initialize
      profile.save!(validate: false)
      affiliate.youtube_profiles << profile unless affiliate.youtube_profiles.exists?(id: profile.id)
      affiliate.rss_feeds.where(is_managed: true).first_or_create!(name: 'Videos')
    end if hash[:youtube_handles].present?

    hash[:domains].split(',').each { |domain| affiliate.site_domains.create!(domain: domain) } if hash[:domains].present?
    affiliate.assign_sitelink_generator_names!
  end
  ElasticNewsItem.recreate_index
end

Given /^the following Misspelling exist:$/ do |table|
  table.hashes.each do |hash|
    Misspelling.create!(:wrong => hash["wrong"], :rite => hash["rite"])
  end
end

Then /^the search bar should have SAYT enabled$/ do
  page.should have_selector("input[id='search_query'][type='text'][class='usagov-search-autocomplete'][autocomplete='off']")
end

Then /^the search bar should not have SAYT enabled$/ do
  page.should_not have_selector("input[id='search_query'][type='text'][class='usagov-search-autocomplete'][autocomplete='off']")
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
  page.body.should match(%r{var usagov_sayt_url = "http://www.example.com/sayt\?aid=#{affiliate.id}})
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  page.body.should_not match("aid=#{affiliate.id}")
end

Then /^the "([^\"]*)" button should be checked$/ do |field|
  page.should have_selector "input[type='radio'][checked='checked'][id='#{field}']"
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
    page.should have_selector("table.generic-table tbody tr#site_#{site.id} td.site-name a", :text => site.display_name)
  end
end

Then /^I should see "([^\"]*)" in the site wizards header$/ do |step|
  page.should have_selector(".steps_header img[alt='#{step}']")
end

Then /^I should see the code for (English|Spanish) language sites$/ do |locale|
  locales = { 'English' => 'en', 'Spanish' => 'es' }
  page.should have_selector("#embed_code_textarea_#{locales[locale]}")
end

Then /^I should see the affiliate custom css$/ do
  page.should have_selector("head style")
end

Then /^I should see some (Bing|Azure) search results$/ do |engine|
  page.should have_selector("#results > .searchresult")
  step "I should see the Results by #{engine} logo"
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

Then /^I should not see the page with internal CSS "([^"]*)"$/ do |css|
  page.body.should_not match(css)
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
    affiliate.connections.create!(connected_affiliate: connected_affiliate, label: hash[:display_name])
  end
end

Then /^the "([^"]*)" field should contain site ID for (.+)$/ do |label, affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  step %{the "#{label}" field should contain "#{affiliate.id}"}
end

Given /^the following SystemAlerts exist:$/ do |table|
  table.hashes.each do |hash|
    start_at = case hash[:start_at]
                 when 'today'
                   DateTime.current
                 when /^[[:alpha:]]/
                   DateTime.current.send(hash[:start_at].gsub(/\s+/, '_').to_sym)
                 else nil
               end
    end_at = case hash[:end_at]
               when 'today'
                 DateTime.current
               when /^[[:alpha:]]/
                 DateTime.current.send(hash[:end_at].gsub(/\s+/, '_').to_sym)
               else nil
             end
    SystemAlert.create!(:message => hash[:message],
                        :start_at => start_at,
                        :end_at => end_at)
  end
end

When /^the Affiliate "(.*?)" has the following users:$/ do |name, table|
  affiliate = Affiliate.find_by_name name
  table.hashes.each do |hash|
    user = User.find_by_email hash[:email]
    affiliate.memberships.create!(user: user)
  end
end

When /^the rss govbox is enabled for the site "(.*?)"$/ do |name|
  site = Affiliate.find_by_name name
  site.update_attributes!(is_rss_govbox_enabled: true)
end

Given(/^"(.*?)" is an affiliate$/) do |email|
  User.find_by_email(email).update_attribute(:is_affiliate, true)
end

Given /^the following "(.+)" exist for the affiliate (.+):$/ do |association, affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  association.gsub!(' ','_')
  table.hashes.each {|hash|  affiliate.send(association).create!(hash) }
end

Given /^the following templates are available for the affiliate (.+):$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name)
  table.hashes.each do |table|
    template = Template.find_by_name(table[:name])
    affiliate.affiliate_templates.create!( template_id: template.id)
  end
end
