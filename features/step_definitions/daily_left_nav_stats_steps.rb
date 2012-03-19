Given /^affiliate "([^"]*)" has the following DailyLeftNavStats:$/ do |affiliate_name, table|
  affiliate = Affiliate.find_by_name affiliate_name
  table.hashes.each do |hash|
    day = hash[:days_back].to_i.days.ago
    affiliate.daily_left_nav_stats.create!(:day => day, :search_type => hash[:search_type], :params => hash[:params], :total => hash[:total])
  end
end
