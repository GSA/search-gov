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
      :organization_name=> "Agency"
    }
    user = User.find_by_email(hash["contact_email"]) || User.create!( valid_options )
    user.update_attribute(:is_affiliate, true)
    Affiliate.create(
      :name => hash["name"],
      :user => user,
      :domains => hash["domains"],
      :header => hash["header"],
      :footer => hash["footer"],
      :staged_domains => hash["staged_domains"],
      :staged_header => hash["staged_header"],
      :staged_footer => hash["staged_footer"],
      :is_sayt_enabled => hash["is_sayt_enabled"],
      :is_affiliate_suggestions_enabled => hash["is_affiliate_suggestions_enabled"]
    )
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

Then /^affiliate SAYT suggestions for "([^\"]*)" should be enabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  response.body.should have_tag("script[type=text/javascript]", :text => "\n    //\n    var usagov_sayt_url = \"#{root_url}sayt?aid=#{affiliate.id}&\";\n    //\n    ")
end

Then /^affiliate SAYT suggestions for "([^\"]*)" should be disabled$/ do |affiliate_name|
  affiliate = Affiliate.find_by_name(affiliate_name)
  response.body.should_not have_tag("script[type=text/javascript]", :text => "\n    //\n    var usagov_sayt_url = \"#{root_url}sayt?aid=#{affiliate.id}&\";\n    //\n    ")
end