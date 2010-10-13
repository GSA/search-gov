Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
  DailyQueryStat.reindex
end

Given /^there are no query accelerations stats$/ do
  MovingQuery.delete_all
end

Given /^there is analytics data from "([^\"]*)" thru "([^\"]*)"$/ do |sd, ed|
  DailyQueryStat.delete_all
  startdate, enddate = sd.to_date, ed.to_date
  cnt = 10000
  words = ("aaaa".."aaaz").to_a
  startdate.upto(enddate) do |day|
    words.each do |word|
      cnt = cnt -1
      DailyQueryStat.create(:day => day, :query => word, :times => cnt, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      MovingQuery.create(:day => day, :query => word, :times => cnt, :mean => 1.0, :std_dev => 0.001)
    end
  end
  DailyQueryStat.reindex
end

Given /^the following DailyQueryStats exist:$/ do |table|
  DailyQueryStat.delete_all
  table.hashes.each do |hash|
    DailyQueryStat.create(:day => hash["days_back"].nil? ? Date.yesterday : hash["days_back"].to_i.day.ago,
                          :query => hash["query"],
                          :times => hash["times"],
                          :affiliate => hash["affiliate"].nil? ? Affiliate::USAGOV_AFFILIATE_NAME : hash["affiliate"],
                          :locale => hash["locale"].nil? ? I18n.default_locale.to_s : hash["locale"])
  end
  DailyQueryStat.reindex
end

Given /^the following query groups exist:$/ do |table|
  table.hashes.each do |hash|
    qg = QueryGroup.find_or_create_by_name(:name => hash["group"])
    gqs = hash["queries"].split(",").collect { |query| GroupedQuery.find_or_create_by_query(:query=> query.strip) }
    qg.grouped_queries << gqs
  end
end

Then /^I should see the download prompt for yesterday$/ do
  response.body.should contain(/Download CSV of top 1000 queries for #{ Date.yesterday.to_s }/)
end

Given /^the DailyContextualQueryTotal for yesterday is "([^\"]*)"$/ do |total|
  DailyContextualQueryTotal.create(:day => Date.yesterday, :total => total)
end