Given /^the following FAQs exist:$/ do |table|
  table.hashes.each do |hash|
    Faq.create!(:url => hash["url"], :question => hash["question"], :answer => hash["answer"], :ranking => hash["ranking"], :locale => hash["locale"])
  end
  Sunspot.commit
end

Given /^the following Calais Related Searches exist:$/ do |table|
  table.hashes.each do |hash|
    CalaisRelatedSearch.create!(:term => hash["term"], :related_terms => hash["related_terms"], :locale => hash["locale"])
  end
  Sunspot.commit
end

Given /^the following Popular Image Query entries exist:$/ do |table|
  table.hashes.each do |hash|
    PopularImageQuery.create!(:query => hash[:query])
  end
end

Then /^I should see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
end

Then /^I should not see "([^"]*)" after the (\d+)th search result$/ do |value, position|
  page.should_not have_selector("#results div:nth-of-type(#{position.to_i + 2})", :text => value)
end

