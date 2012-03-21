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