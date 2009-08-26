Given /^there are no daily query stats for the last (\d+) days?$/ do |num_days|
  1.upto(num_days.to_i) { |offset| DailyQueryStat.delete_all(["day = ?",offset.days.ago.to_date]) }
end
