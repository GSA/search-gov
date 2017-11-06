Then /^I should see (\d+) image results?$/ do |num_results|
  count = num_results.to_i
  html = Nokogiri::HTML(page.body)
  responsive_results = html.search('.content-block-item.result.image')
  legacy_results = html.search(".image_result")
  (responsive_results.size == count) || (legacy_results.size == count)
end
