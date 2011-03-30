Then /^I should see (\d+) search results$/ do |num_results|
  page.body.should =~ /searchresult#{num_results}/
end

When /^I submit the search form$/ do
  click_button('Search')
end

When /^I fill in "([^\"]*)" with a (\d+) character string$/ do |field, str_length|
  str = "x"*str_length.to_i
  fill_in(field, :with => str)
end
