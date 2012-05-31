Then /^I should see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
end

Then /^I should not see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should_not have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
end

Given /^the following Agency entries exist:$/ do |table|
  table.hashes.each do |hash|
    Agency.create!(:name => hash[:name], :domain => hash[:domain])
  end
end

Given /^the following Agency Urls exist:$/ do |table|
  table.hashes.each do |hash|
    agency = Agency.find_by_name(hash[:name])
    agency.agency_urls.create!(:locale => hash[:locale], :url => hash[:url])
  end
end
