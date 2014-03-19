Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
end

Given /^the following DailyQueryStats exist:$/ do |table|
  DailyQueryStat.delete_all
  table.hashes.each do |hash|
    DailyQueryStat.create!(:day => hash["days_back"].nil? ? Date.yesterday : Date.current.advance(:days => -(hash["days_back"].to_i)),
                           :query => hash["query"],
                           :times => hash["times"],
                           :affiliate => hash["affiliate"],
                           :locale => hash["locale"].nil? ? I18n.default_locale.to_s : hash["locale"])
  end
  ElasticDailyQueryStat.commit
end

Given /^the following DailyQueryStats exist for affiliate "([^\"]*)":$/ do |affiliate_name, table|
  DailyQueryStat.delete_all
  table.hashes.each { |hash| DailyQueryStat.create!(:day => hash["day"].to_date, :query => hash["query"], :times => hash["times"], :affiliate => affiliate_name) }
  ElasticDailyQueryStat.commit
end

Given /^the following NoResultsStats exist for affiliate "([^\"]*)":$/ do |affiliate_name, table|
  DailyQueryNoresultsStat.delete_all
  table.hashes.each do |hash|
    DailyQueryNoresultsStat.create!(:day => hash["day"].to_date, :query => hash["query"], :times => hash["times"], :affiliate => affiliate_name)
  end
end

Given /^affiliate "(.*?)" has the following DailyClickStats:$/ do |affiliate_name, table|
  DailyClickStat.delete_all
  table.hashes.each do |hash|
    DailyClickStat.create!(:day => hash["day"].to_date, :url => hash["url"], :times => hash["times"], :affiliate => affiliate_name)
  end
end

Given /^affiliate "(.*?)" has the following QueriesClicksStats:$/ do |affiliate_name, table|
  QueriesClicksStat.delete_all
  table.hashes.each do |hash|
    QueriesClicksStat.create!(:day => hash["day"].to_date, :url => hash["url"], :query => hash["query"], :times => hash["times"], :affiliate => affiliate_name)
  end
end