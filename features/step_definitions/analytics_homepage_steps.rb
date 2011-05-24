Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
  DailyQueryStat.reindex
end

Given /^there are no query accelerations stats$/ do
  MovingQuery.delete_all
end

Given /^there are no zero result query stats$/ do
  DailyQueryNoresultsStat.delete_all
end

Given /^there is analytics data from "([^\"]*)" thru "([^\"]*)"$/ do |sd, ed|
  DailyQueryStat.delete_all
  startdate, enddate = sd.to_date, ed.to_date
  cnt = 10000
  words = ("aaaa".."aaaz").to_a
  startdate.upto(enddate) do |day|
    words.each do |word|
      cnt = cnt - 1
      DailyQueryStat.create!(:day => day, :query => word, :times => cnt, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      MovingQuery.create!(:day => day, :query => word, :times => cnt, :mean => 1.0, :std_dev => 0.001)
      DailyQueryNoresultsStat.create!(:day => day, :query => "gobbledegook #{word}", :affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :locale => "en", :times => cnt)
    end
  end
  DailyQueryStat.reindex
end

Given /^there is popular query data from "([^"]*)" thru "([^"]*)"$/ do |sd, ed|
  DailyPopularQuery.delete_all
  start_date, end_date = sd.to_date, ed.to_date
  cnt = 10000
  words = ("aaaa".."aaaz").to_a
  start_date.upto(end_date) do |day|
    words.each do |word|
      cnt = cnt - 1
      DailyPopularQuery.create!(:day => day, :query => word, :times => cnt, :is_grouped => false, :time_frame => 1, :locale => I18n.default_locale.to_s)
      DailyPopularQuery.create!(:day => day, :query => word, :times => cnt, :is_grouped => false, :time_frame => 7, :locale => I18n.default_locale.to_s)
      DailyPopularQuery.create!(:day => day, :query => word, :times => cnt, :is_grouped => false, :time_frame => 30, :locale => I18n.default_locale.to_s)
    end
  end
end

Given /^the following DailyPopularQueries exist for yesterday:$/ do |table|
  DailyPopularQuery.delete_all
  table.hashes.each do |hash|
    Affiliate.find_by_name(hash["affiliate"]) if hash["affiliate"].present?
    DailyPopularQuery.create!(:day => Date.yesterday, :query => hash["query"], :times => hash["times"], :time_frame => hash["time_frame"], :is_grouped => hash["is_grouped"] == "true" ? true : false, :locale => I18n.default_locale.to_s)
  end
end


Given /^the following DailyQueryStats exist:$/ do |table|
  DailyQueryStat.delete_all
  table.hashes.each do |hash|
    DailyQueryStat.create!(:day => hash["days_back"].nil? ? Date.yesterday : Date.current.advance(:days => -(hash["days_back"].to_i)),
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

Given /^the DailyContextualQueryTotal for yesterday is "([^\"]*)"$/ do |total|
  DailyContextualQueryTotal.create!(:day => Date.yesterday, :total => total)
end

Given /^no DailyContextualQueryTotals exist$/ do
  DailyContextualQueryTotal.delete_all
end
