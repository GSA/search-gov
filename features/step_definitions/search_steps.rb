Then /^I should see at least "([^"]*)" web search results?$/ do |count|
  page.should have_selector("#results #result-#{count}")
end

Then /^I should see (exactly|at least) "([^"]*)" video( govbox)? search results?$/ do |is_exact, count, is_govbox|
  if is_exact == 'exactly'
    selector = is_govbox.present? ? '#video-news-items .result.video' : '#results .result.video'
    page.should have_selector selector, count: count
  else
    selector = is_govbox.present? ? "#video-news-items #video-news-item-#{count}" : "#results #result-#{count}"
    page.should have_selector selector
  end
end

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

Then(/^I should see (Powered by|Generado por) Bing logo$/) do |text|
  page.should have_selector '.content-provider .bing', text: text
end
