Then /^I should see (\d+) search results$/ do |num_results|
  response.body.should =~ /searchresult#{num_results}/
end

When /^I submit the search form$/ do
  submit_form('search_form')
end