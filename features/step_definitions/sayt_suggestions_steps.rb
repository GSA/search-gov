Given /^the following SAYT Suggestions exist(?: for (.*))?:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name(affiliate_name) unless affiliate_name.blank?
  affiliate.sayt_suggestions.destroy_all
  table.hashes.each { |hash| affiliate.sayt_suggestions.create!(phrase: hash[:phrase]) }
  ElasticSaytSuggestion.commit
end

Then /^I should see (\d+) related searches$/ do |count|
  page.should have_selector('#related-searches a', count: count)
end

Then /^I should see (\d+) type\-ahead search suggestions$/ do |count|
  page.should have_selector("#sayt-suggestions .sayt_suggestion", :count => count)
end

Then /^I should not see any type\-ahead search suggestion$/ do
  page.should_not have_selector("#sayt-suggestions .sayt_suggestion")
end
