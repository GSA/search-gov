Given /^the following DailyUsageStats exists for each day in yesterday's month$/ do |table|
  DailyUsageStat.delete_all
  yday = Date.yesterday
  table.hashes.each do |hash|
    yday.day.times do |index|
      DailyUsageStat.create!(:day => yday - index, :total_queries => hash["total_queries"], :affiliate => hash["affiliate"])
    end
  end
end

Given /^the following DailyUsageStats exist for each day in "([^\"]*)"$/ do |month, table|
  DailyUsageStat.delete_all
  month_date = Date.parse(month + "-01")
  table.hashes.each do |hash|
    (Date.new(Time.now.year, 12, 31).to_date<<(12-month_date.month)).day.times do |index|
      DailyUsageStat.create!(:day => month_date + index.days, :total_queries => hash["total_queries"], :affiliate => hash["affiliate"])
    end
  end
end

Then /^I should see the header for the report date$/ do
  page.body.should match("Monthly Usage Stats for #{Date::MONTHNAMES[Date.yesterday.month]} #{Date.yesterday.year}")
end

Then /^I should see the "([^\"]*)" queries total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.yesterday.day
  page.body.should match("Total Queries: #{value.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse}")
end

Then /^I should see the "([^\"]*)" page views total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.yesterday.day
  page.body.should match("Total Page Views: #{value.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse}")
end

Then /^I should see the "([^\"]*)" unique visitors total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.yesterday.day
  page.body.should match("Total Unique Visitors: #{value.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse}")
end

Then /^I should see the "([^\"]*)" clicks total within "([^\"]*)"$/ do |profile, selector|
  value = 10 * Date.yesterday.day
  page.body.should match("Total Click Throughs: #{value.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse}")
end

Then /^I should see the report header for "([^\"]*)"$/ do |month|
  date = Date.parse(month + "-01")
  page.body.should match("Monthly Usage Stats for #{Date::MONTHNAMES[date.month]} #{date.year}")
end

Then /^I should see the "([^\"]*)" "([^\"]*)" total within "([^\"]*)" with a total of "([^\"]*)"$/ do |profile, stat_name, selector, total|
  page.body.should match("Total #{stat_name}: #{total}")
end

Given /^I select "([^\"]*)" as the report date$/ do |date_string|
  date = Date.parse(date_string)
  select date.year.to_s, :from => "date[year]"
  select date.strftime('%B'), :from => "date[month]"
end

Then /^I should see a total for "([^"]*)" with a total of "([^"]*)"( per day)?$/ do |affiliate, total, daily|
  total = daily ? Date.yesterday.day * total.to_i : total.to_i
  text = %r[#{Regexp.escape(affiliate)} \(\d+\): #{total}]
  page.should have_xpath('//*', text: text)
end

