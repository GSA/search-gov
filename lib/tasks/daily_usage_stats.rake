namespace :usasearch do
  desc "Runs nightly to compile webtrends usage stats for the previous few days, updating existing records in DB"
  task :update_webtrends_stats, :start_day, :end_day, :needs => :environment do |t, args|
    args.with_defaults(:start_day => (Date.yesterday - 2.days).to_s(:number), :end_day => Date.yesterday.to_s(:number))
    start_date, end_date = Date.parse(args.start_day), Date.parse(args.end_day)
    start_date.upto(end_date) { |date| DailyUsageStat.update_webtrends_stats_for(date) }
  end
end