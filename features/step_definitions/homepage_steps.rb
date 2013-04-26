Then /^I should see (\d+) search results$/ do |num_results|
  page.body.should =~ /searchresult#{num_results}/
end

Then /^I should see at least (\d+) search results$/ do |num_results|
  page.body.should =~ /searchresult#{num_results}/
end

When /^I submit the search form$/ do
  click_button('Search')
end