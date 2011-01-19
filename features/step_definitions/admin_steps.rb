Given /^the following Top Searches exist:$/ do |table|
  TopSearch.destroy_all
  table.hashes.each do |hash|
    TopSearch.create(:position => hash["position"], :query => hash["query"], :url => hash["url"].blank? ? nil : hash["url"])
  end
end

Given /^the following Top Forms exist:$/ do |table|
  TopForm.destroy_all
  table.hashes.each do |hash|
    TopForm.create(:name => hash["name"], :url => hash["url"].blank? ? nil : hash["url"], :column_number => hash[:column_number], :sort_order => hash["sort_order"])
  end
end

Then /^I should see "([^\"]*)" as a Top Form name$/ do |form_name|
  response.body.should have_tag("input[id=top_form_name][value=#{form_name}]")
end

Then /^I should not see "([^\"]*)" as a Top Form name$/ do |form_name|
  response.body.should_not have_tag("input[id=top_form_name][value=#{form_name}]")
end
