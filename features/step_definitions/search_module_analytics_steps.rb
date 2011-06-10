Given /^the following search modules exist:$/ do |table|
  SearchModule.delete_all
  table.hashes.each { |hash| SearchModule.create!(:tag => hash["tag"], :display_name => hash["display_name"]) }
end

Given /^the following search module data exists for "([^"]*)":$/ do |day, table|
  DailySearchModuleStat.delete_all
  table.hashes.each do |hash|
    DailySearchModuleStat.create!(:affiliate_name => hash["affiliate_name"], :module_tag => hash["module_tag"],
                                  :vertical => hash["vertical"], :locale => hash["locale"], :day => Date.parse(day),
                                  :impressions => hash["impressions"], :clicks => hash["clicks"])
  end
end

Given /^no search module data exists$/ do
  DailySearchModuleStat.delete_all
end