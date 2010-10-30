namespace :usasearch do
  desc "Runs nightly to compile webtrends usage stats for the previous day and update existing record in DB"
  task :update_webtrends_stats => :environment do
    DailyUsageStat.update_webtrends_stats_for(Date.yesterday)
  end

  desc "Compute daily contextual query total"
  task :compute_daily_contextual_query_total, :day, :needs => :environment do |t, args|
    day = args.day.present? ? Date.parse(args.day) : Date.yesterday
    DailyContextualQueryTotal.destroy_all(['day=?', day])
    DailyContextualQueryTotal.create(:day => day)
  end
end