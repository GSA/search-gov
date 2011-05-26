When /^I should see (\d+) search trends$/ do |count|
  page.should have_selector("#home_searchtrend>ul>li>a[target='_top']", :count => count)
end

When /^I should see (\d+) top searches$/ do |count|
  page.should have_selector("#most_popular ol>li>a[target='_top']", :count => count)
end

