Then /^I should see the Results by Bing logo$/ do
  page.should have_selector("img[src^='/images/binglogo_en.gif']")
end

Then /^I should see the Results by USASearch logo$/ do
  page.should have_selector("img[src^='/images/results_by_usasearch_en.png']")
end