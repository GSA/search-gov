namespace :usasearch do
  desc "Runs nightly to compile usage stats for the previous day"
  task :compile_usage_stats_for_yesterday => :environment do
    yesterday = Date.yesterday
    DailyUsageStat.delete_all(["day = ?", yesterday])
    DailyUsageStat::PROFILES.each do |profile_name, profile_data|
      @daily_usage_stat = DailyUsageStat.new(:day => yesterday, :profile => profile_name)
      @daily_usage_stat.populate_data
      if !@daily_usage_stat.save
        RAILS_DEFAULT_LOGGER.error("Error computing daily usage stats: #{@daily_usage_stat.errors}")
      end
    end
  end

  task :update_usage_stats, :start_date, :end_date, :needs => :environment do |t, args|
    if args.start_date.blank? || args.end_date.blank?
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:update_usage_stats start_date, end_date (Dates should look like: '2010-03-01')")
    else
      start_date = Date.parse(args.start_date)
      end_date = Date.parse(args.end_date)
      DailyUsageStat.delete_all(["day between ? and ?", start_date, end_date])
      start_date.upto(end_date) do |report_date|
        DailyUsageStat::PROFILE_NAMES.each do |profile_name|
          @daily_usage_stat = DailyUsageStat.new(:day => report_date, :profile => profile_name)
          @daily_usage_stat.populate_data
          if !@daily_usage_stat.save
            RAILS_DEFAULT_LOGGER.error @daily_usage_stat.errors
          end
        end
      end
    end
  end

end