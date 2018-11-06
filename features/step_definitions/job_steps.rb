Then /^I should see (\d+) job postings?$/ do |num_results|
  html = Nokogiri::HTML(page.body)
  job_postings = html.search('.content-block-item.job.result')
  job_postings.size == num_results.to_i
end
