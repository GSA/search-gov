Given /^there are no query accelerations stats$/ do
  MovingQuery.delete_all
end

Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
end

Given /^there are no zero result query stats$/ do
  DailyQueryNoresultsStat.delete_all
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
  Sunspot.commit
end

Given /^the following DailyQueryStats exist for affiliate "([^\"]*)":$/ do |affiliate_name, table|
  DailyQueryStat.delete_all
  table.hashes.each { |hash| DailyQueryStat.create!(:day => hash["day"].to_date, :query => hash["query"], :times => hash["times"], :affiliate => affiliate_name) }
  Sunspot.commit
end

Given /^the following NoResultsStats exist for affiliate "([^\"]*)":$/ do |affiliate_name, table|
  DailyQueryNoresultsStat.delete_all
  table.hashes.each { |hash| DailyQueryNoresultsStat.create!(:day => hash["day"].to_date, :query => hash["query"], :times => hash["times"], :affiliate => affiliate_name, :locale => I18n.default_locale.to_s) }
end

Given /^the following query groups exist:$/ do |table|
  table.hashes.each do |hash|
    qg = QueryGroup.find_or_create_by_name(:name => hash["group"])
    gqs = hash["queries"].split(",").collect { |query| GroupedQuery.find_or_create_by_query(:query=> query.strip) }
    qg.grouped_queries << gqs
  end
end

Given /^the following DailyPopularQueryGroups exist for "([^\"]*)":$/ do |day, table|
  DailyPopularQueryGroup.delete_all
  table.hashes.each do |hash|
    DailyPopularQueryGroup.create!(:day => day.to_date, :query_group_name => hash["query_group"], :times => hash["times"], :time_frame => hash["time_frame"])
  end
end

Given /^the following MovingQueries exist for "([^\"]*)":$/ do |day, table|
  MovingQuery.delete_all
  table.hashes.each do |hash|
    MovingQuery.create!(:day => day.to_date, :query => hash["query"], :times => hash["times"], :mean => 1.0, :std_dev => 0.001)
  end
  1.upto(7) { |offset| MovingQuery.create!(:day => (day.to_date - offset.days), :query => "for sufficient data", :times => 10, :mean => 1.0, :std_dev => 0.001) }
end
