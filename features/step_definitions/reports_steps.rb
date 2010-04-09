Given /^the following DailyUsageStats exist for yesterday:$/ do |table|
  DailyUsageStat.delete_all
  table.hashes.each do |hash|
    DailyUsageStat.create(:day => Date.yesterday, :profile => hash["profile"], :total_queries => hash["total_queries"], :total_page_views => hash["total_page_views"], :total_unique_visitors => hash["total_unique_visitors"], :total_clicks => hash["total_clicks"])
  end
end

Given /^the following DailyUsageStats exists for each day in the current month$/ do |table|
  DailyUsageStat.delete_all
  today = Date.today
  table.hashes.each do |hash|
    Date.today.day.times do |index|
      date = today - index
      DailyUsageStat.create(:day => date, :profile => hash["profile"], :total_queries => hash["total_queries"], :total_page_views => hash["total_page_views"], :total_unique_visitors => hash["total_unique_visitors"], :total_clicks => hash["total_clicks"])
    end
  end
end

Given /^the following DailyUsageStats exist for each day in "([^\"]*)"$/ do |month, table|
  DailyUsageStat.delete_all
  month_date = Date.parse(month + "-01")
  table.hashes.each do |hash|
    (Date.new(Time.now.year,12,31).to_date<<(12-month_date.month)).day.times do |index|
      DailyUsageStat.create(:day => month_date + index.days, :profile => hash["profile"], :total_queries => hash["total_queries"], :total_page_views => hash["total_page_views"], :total_unique_visitors => hash["total_unique_visitors"], :total_clicks => hash["total_clicks"])
    end
  end
end


Then /^I should see the header for the current date$/ do
  response.should contain("Monthly Usage Stats for #{Date::MONTHNAMES[Date.today.month]} #{Date.today.year}")
  response.should contain("(current as of #{Date.yesterday.strftime('%B %e, %Y').squish})")
end

Then /^I should see the "([^\"]*)" queries total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.today.day
  response.should contain("Total Queries: #{value.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}")
end

Then /^I should see the "([^\"]*)" page views total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.today.day
  response.should contain("Total Page Views: #{value.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}")
end

Then /^I should see the "([^\"]*)" unique visitors total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.today.day
  response.should contain("Total Unique Visitors: #{value.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}")
end

Then /^I should see the "([^\"]*)" clicks total within "([^\"]*)"$/ do |profile, selector|
  value = 1000 * Date.today.day
  response.should contain("Total Click Throughs: #{value.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}")
end

Then /^I should see the report header for "([^\"]*)"$/ do |month|
  date = Date.parse(month + "-01")
  response.should contain("Monthly Usage Stats for #{Date::MONTHNAMES[date.month]} #{date.year}")
end

Then /^I should see the "([^\"]*)" "([^\"]*)" total within "([^\"]*)" with a total of "([^\"]*)"$/ do |profile, stat_name, selector, total|
  response.should contain("Total #{stat_name}: #{total}")
end

Given /^I select "([^\"]*)" as the report date$/ do |date_string|
  date = Date.parse(date_string)
  select date.year, :from => "date[year]"
  select date.strftime('%B'), :from => "date[month]"
end


