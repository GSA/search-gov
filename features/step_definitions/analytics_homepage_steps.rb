Given /^there are no daily query stats$/ do
  DailyQueryStat.delete_all
end

Given /^there are no query accelerations stats$/ do
  QueryAcceleration.delete_all
end

Given /^there is analytics data from "([^\"]*)" thru "([^\"]*)"$/ do |sd, ed|
  startdate, enddate = sd.to_date, ed.to_date
  wordcount = 5
  words = []
  startword = "aaaa"
  wordcount.times {words << startword.succ!}
  startdate.upto(enddate) do |day|
    words.each do |word|
      times = rand(1000)
      DailyQueryStat.create(:day => day, :query => word, :times => times)
      [1, 7, 30].each { |window_size| QueryAcceleration.create(:day => day, :query => word, :window_size => window_size, :score => window_size * times) }
    end
  end
end