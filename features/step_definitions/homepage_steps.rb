# legacy SERP
Then /^I should see (\d+) search results$/ do |num_results|
  page.body.should =~ /searchresult#{num_results}/
end

# legacy SERP
Then /^I should see at least (\d+) search results$/ do |num_results|
  page.body.should =~ /searchresult#{num_results}/
end
