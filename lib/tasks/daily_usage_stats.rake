namespace :usasearch do
  desc "Runs nightly to compile webtrends usage stats for the previous day and update existing record in DB"
  task :update_webtrends_stats => :environment do
    DailyUsageStat.update_webtrends_stats_for(Date.yesterday)
  end
end