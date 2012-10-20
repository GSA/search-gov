Given /^affiliate "([^"]*)" has the following DailyLeftNavStats:$/ do |affiliate_name, table|
  table.hashes.each do |hash|
    day = hash[:days_back].to_i.days.ago
    DailyLeftNavStat.create!(:affiliate => affiliate_name, :day => day, :search_type => hash[:search_type], :params => hash[:params], :total => hash[:total])
  end
end
