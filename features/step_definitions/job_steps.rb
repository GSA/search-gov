Then /^I should see (\d+) job postings?$/ do |num_results|
  page.should have_selector('.content-block-item.job.result')
end

Then /I should see an annual salary/ do
  annual_salary_regex = /\$\d{2,3},\d{3}\.\d{2}\+\/yr/
  page.should have_selector('.job-locations-money', text: annual_salary_regex)
end

Then /I should see an application deadline/ do
  deadline_regex = /Apply by [[:alpha:]]+ \d{1,2}, \d{4}/
  page.should have_selector('.job-dates', text: deadline_regex)
end
