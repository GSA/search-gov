Given /^there are no query accelerations stats$/ do
  MovingQuery.delete_all
end

Given /^there are no daily popular query stats$/ do
  DailyPopularQuery.delete_all
end

Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
end

Given /^there are no zero result query stats$/ do
  DailyQueryNoresultsStat.delete_all
end

Given /^there is analytics data from "([^\"]*)" thru "([^\"]*)" for affiliate "([^\"]*)"$/ do |sd, ed, affiliate_name|
  DailyPopularQuery.delete_all
  affiliate = Affiliate.find_by_name(affiliate_name)
  startdate, enddate = sd.to_date, ed.to_date
  cnt = 10000
  words = ("aaaa".."aaaz").to_a
  startdate.upto(enddate) do |day|
    words.each do |word|
      cnt = cnt - 1
      MovingQuery.create!(:day => day, :query => "top mover #{word}", :times => cnt, :mean => 1.0, :std_dev => 0.001)
      DailyQueryNoresultsStat.create!(:day => day, :query => "gobbledegook #{word}", :affiliate => affiliate_name, :locale => I18n.default_locale.to_s, :times => cnt)
      [1, 7, 30].each { |time_frame| DailyPopularQuery.create!(:day => day, :query => "most popular #{time_frame} #{word}", :times => cnt, :is_grouped => false, :time_frame => time_frame, :locale => I18n.default_locale.to_s, :affiliate => affiliate) }
    end
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

Given /^the following DailyPopularQueries exist for yesterday:$/ do |table|
  DailyPopularQuery.delete_all
  table.hashes.each do |hash|
    affiliate = hash["affiliate"].present? ? Affiliate.find_by_name(hash["affiliate"]) : nil
    DailyPopularQuery.create!(:day => Date.yesterday, :query => hash["query"], :times => hash["times"], :time_frame => hash["time_frame"],
                              :is_grouped => hash["is_grouped"] == "true" ? true : false, :locale => I18n.default_locale.to_s, :affiliate => affiliate)
  end
end
