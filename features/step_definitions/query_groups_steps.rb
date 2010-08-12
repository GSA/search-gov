Given /^the following query_groups:$/ do |query_groups|
  QueryGroups.create!(query_groups.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) query_groups$/ do |pos|
  visit query_groups_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following query_groups:$/ do |expected_query_groups_table|
  expected_query_groups_table.diff!(tableish('table tr', 'td,th'))
end

When /^I fill in "([^\"]*)" with the following text:$/ do |field, queries|
  fill_in(field, :with => queries)
end

