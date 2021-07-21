Then /^I should see (\d+) image results?$/ do |num_results|
  count = num_results.to_i
  html = Nokogiri::HTML(page.body)
  results = html.search('.content-block-item.result.image')
  results.size == count
end
