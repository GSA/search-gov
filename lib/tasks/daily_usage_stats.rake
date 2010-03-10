namespace :usasearch do
  desc "Runs nightly to compile usage stats for the previous day"
  task :compile_usage_stats_for_yesterday => :environment do
    yesterday = Date.yesterday
    DailyUsageStat.delete_all(["day = ?", yesterday])
    DailyUsageStat::Profiles.each do |profile_name, profile_data|
      @daily_usage_stat = DailyUsageStat.new(:day => yesterday, :profile => profile_name)
      @daily_usage_stat.populate_data
      if !@daily_usage_stat.save
        RAILS_DEFAULT_LOGGER.error("Error computing daily usage stats: #{@daily_usage_stat.errors}")
      end
    end
  end
end