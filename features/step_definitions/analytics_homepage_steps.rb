Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
end

Given /^there are no query accelerations stats$/ do
  MovingQuery.delete_all
end

Given /^there is analytics data from "([^\"]*)" thru "([^\"]*)"$/ do |sd, ed|
  DailyQueryStat.delete_all
  startdate, enddate = sd.to_date, ed.to_date
  wordcount = 5
  words = []
  startword = "aaaa"
  wordcount.times {words << startword.succ!}
  startdate.upto(enddate) do |day|
    words.each do |word|
      times = rand(1000)
      DailyQueryStat.create(:day => day, :query => word, :times => times, :affiliate => DailyQueryStat::DEFAULT_AFFILIATE_NAME)
      [1, 7, 30].each { |window_size| MovingQuery.create(:day => day, :query => word, :window_size => window_size, :times => window_size * times, :mean => 1.0, :std_dev => 0.001) }
    end
  end
end

Given /^the following DailyQueryStats exist for yesterday:$/ do |table|
  DailyQueryStat.delete_all
  table.hashes.each do |hash|
    DailyQueryStat.create(:day => Date.yesterday, :query => hash["query"], :times => hash["times"], :affiliate => hash["affiliate"].nil? ? DailyQueryStat::DEFAULT_AFFILIATE_NAME : hash["affiliate"], :locale => hash["locale"].nil? ? I18n.default_locale.to_s : hash["locale"])
  end
end


Given /^the following query groups exist:$/ do |table|
  table.hashes.each do |hash|
    qg = QueryGroup.find_or_create_by_name(:name => hash["group"])
    gqs = hash["queries"].split(",").collect{|query| GroupedQuery.find_or_create_by_query(:query=> query.strip)}
    qg.grouped_queries << gqs
  end
end

Then /^I should see the download prompt for yesterday$/ do
  response.body.should contain(/Download CSV of top 1000 queries for #{ Date.yesterday.to_s }/)
end