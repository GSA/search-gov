Then /^I should see (\d+) image results$/ do |num_results|
  Nokogiri::HTML(page.body).search(".image_result").size.should == num_results.to_i
end