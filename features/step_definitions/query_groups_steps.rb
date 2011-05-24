Then /^I should see the following query_groups:$/ do |expected_query_groups_table|
  expected_query_groups_table.diff!(tableish('table tr', 'td,th'))
end

When /^I fill in "([^\"]*)" with the following text:$/ do |field, queries|
  fill_in(field, :with => queries)
end

When /^I blank out the "([^\"]*)" text area$/ do |field|
  fill_in(field, :with => "")
end
