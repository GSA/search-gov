namespace :usasearch do
  desc "Runs nightly to compile webtrends usage stats for the previous day and update existing record in DB"
  task :update_webtrends_stats => :environment do
    (Date.yesterday - 2.days).upto(Date.yesterday) do |date|
      DailyUsageStat.update_webtrends_stats_for(date)
    end
  end
end