Then /^in "(.*)" I should see "(.*)"$/ do |id, text|
  response.should have_selector("##{id}", :content => text)
end

Then /^in "(.*)" I should not see "(.*)"$/ do |id, text|
  response.should_not have_selector("##{id}", :content => text)
end

Then /^I should land on (.+)$/ do |page_name|
  URI.parse(current_url).to_s.should == path_to(page_name)
end
