When /^I should see (\d+) search trends$/ do |count|
  page.should have_selector("#home_searchtrend>ul>li>a[target='_top']", :count => count)
end
