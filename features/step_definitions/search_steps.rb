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

Given /^the following Agency Popular Urls exist:$/ do |table|
  table.hashes.each do |hash|
    agency = Agency.find_by_name(hash[:name])
    agency.agency_popular_urls.create!(:rank => hash[:rank],
                                       :title => hash[:title],
                                       :url => hash[:url],
                                       :locale => hash[:locale])
  end
end

Then /^I should see a link to "([^"]*)" with url for "([^"]*)" on the popular pages list$/ do |link_title, url|
  page.should have_selector(".popular-pages a", :text => link_title, :href => url)
end

Then /^I should not see a link to "([^"]*)" with url for "([^"]*)" on the popular pages list$/ do |link_title, url|
  page.should_not have_selector(".popular-pages a", :text => link_title, :href => url)
end
