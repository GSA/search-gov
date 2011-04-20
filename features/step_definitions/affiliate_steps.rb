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

    affiliate_template = hash["affiliate_template_name"].blank? ? default_affiliate_template : AffiliateTemplate.find_by_name(hash["affiliate_template_name"])
    staged_affiliate_template = hash["staged_affiliate_template_name"].blank? ? default_affiliate_template : AffiliateTemplate.find_by_name(hash["staged_affiliate_template_name"])

    affiliate = Affiliate.create(
      :display_name => hash["display_name"],
      :name => hash["name"],
      :domains => hash["domains"],
      :affiliate_template_id => affiliate_template.id,
      :header => hash["header"],
      :footer => hash["footer"],
      :staged_domains => hash["staged_domains"],
      :staged_affiliate_template_id => staged_affiliate_template.id,
      :staged_header => hash["staged_header"],
      :staged_footer => hash["staged_footer"],
      :is_sayt_enabled => hash["is_sayt_enabled"],
      :is_affiliate_suggestions_enabled => hash["is_affiliate_suggestions_enabled"],
      :search_results_page_title => hash["search_results_page_title"],
      :staged_search_results_page_title => hash["staged_search_results_page_title"],
      :has_staged_content => hash["has_staged_content"] || false
    )
    affiliate.users << user
  end
end

Given /^there is analytics data for affiliate "([^\"]*)" from "([^\"]*)" thru "([^\"]*)"$/ do |aff, sd, ed|
  DailyQueryStat.delete_all
  startdate, enddate = sd.to_date, ed.to_date
  affiliate = aff
  wordcount = 5
  words = []
  startword = "aaaa"
  wordcount.times {words << startword.succ!}
  startdate.upto(enddate) do |day|
    words.each do |word|
      times = rand(1000)
      DailyQueryStat.create(:day => day, :query => word, :times => times, :affiliate => affiliate)
    end
  end
end

Given /^the following Misspelling exist:$/ do |table|
  table.hashes.each do |hash|
    Misspelling.create!(:wrong => hash["wrong"], :rite => hash["rite"])
  end
end

Then /^the search bar should have SAYT enabled$/ do
  response.body.should have_tag("script[type=text/javascript][src^=/javascripts/sayt-ui.js]")
  response.body.should have_tag("input[id=search_query][type=text][class=usagov-search-autocomplete][autocomplete=off]")
  response.body.should have_tag("script[type=text/javascript][src^=/javascripts/jquery/jquery-ui-1.8.5.custom.min.js]")
end

Then /^the search bar should not have SAYT enabled$/ do
  response.body.should_not have_tag("script[type=text/javascript][src^=/javascripts/sayt-ui.js]")
  response.body.should_not have_tag("input[id=search_query][type=text][class=usagov-search-autocomplete][autocomplete=off]")
  response.body.should_not have_tag("script[type=text/javascript][src^=/javascripts/jquery/jquery-ui-1.8.5.custom.min.js]")
end

Then /^I should see the page with affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  response.body.should have_tag("link[type=text/css][href*=#{stylesheet_name}]")
end

Then /^I should not see the page with affiliate stylesheet "([^\"]*)"/ do |stylesheet_name|
  response.body.should_not have_tag("link[type=text/css][href*=#{stylesheet_name}]")
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be enabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  response.body.should have_tag("script[type=text/javascript]", :text => "\n    //\n    var usagov_sayt_url = \"#{root_url}sayt?aid=#{affiliate.id}&\";\n    //\n    ")
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  response.body.should_not have_tag("script[type=text/javascript]", :text => "\n    //\n    var usagov_sayt_url = \"#{root_url}sayt?aid=#{affiliate.id}&\";\n    //\n    ")
end

Given /^the following Calais Related Searches exist for affiliate "([^\"]*)":$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  CalaisRelatedSearch.delete_all
  table.hashes.each do |hash|
    CalaisRelatedSearch.create!(:term => hash["term"], :related_terms => hash["related_terms"], :locale => hash["locale"], :affiliate => affiliate)
  end
  CalaisRelatedSearch.reindex
end

Then /^the affiliate "([^\"]*)" should be set to use affiliate SAYT$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.is_sayt_enabled.should be_true
  affiliate.is_affiliate_suggestions_enabled.should be_true
end

Then /^the affiliate "([^\"]*)" should be set to use global SAYT$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.is_sayt_enabled.should be_true
  affiliate.is_affiliate_suggestions_enabled.should be_false
end

Then /^the affiliate "([^\"]*)" should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.is_sayt_enabled.should be_false
  affiliate.is_affiliate_suggestions_enabled.should be_false
end

Then /^the "([^\"]*)" button should be checked$/ do |field|
  response_body.should have_selector "input[type=radio][checked=checked][id=#{field}]"
end

Then /^the affiliate "([^\"]*)" should be set to use global related topics$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  affiliate.related_topics_setting.should == 'global_enabled'
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
    response.body.should have_tag("#affiliate_id option:nth-child(#{index + 1})", :value => site.id)
  end
end

Then /^I should see sorted sites in the site list$/ do
  sites = @current_user.affiliates.sort{|x,y| x.display_name <=> y.display_name}
  sites.each_with_index do |site, index|
    response.body.should have_tag(".generic-table tbody tr:nth-child(#{index + 1}) td.site-name a", :text =>site.display_name)
  end
end

Then /^I should see "([^"]*)" in the site wizards header$/ do |step|
  response.body.should have_tag(".steps_header img[alt=#{step}]")
end
