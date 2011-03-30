Then /^I should see an image titled "(.*)"$/ do |title|
  page.should have_selector(%Q{a[title="#{title}"]})
end

Then /^I should see (\d+) image results$/ do |num_results|
  Nokogiri::HTML(page.body).search(".image_result").size.should == num_results.to_i
end