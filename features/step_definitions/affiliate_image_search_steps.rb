Then /^I should see the Results by (Azure|Bing) logo$/ do |engine|
  page.should have_selector("img.results-by-logo.#{engine.downcase}[src^='/assets/searches/binglogo_en']")
end

Then /^I should see the Results by USASearch logo$/ do
  page.should have_selector("img[src^='/assets/searches/results_by_usasearch_en']")
end
