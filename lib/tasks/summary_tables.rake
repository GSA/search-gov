namespace :usasearch do

  namespace :daily_query_stats do
    desc "tell Solr to index the collection of most-recently-added DailyQueryStats (ideally yesterday's)"
    task :index_most_recent_day_stats_in_solr => :environment do
      Sunspot.index(DailyQueryStat.find_all_by_day(DailyQueryStat.most_recent_populated_date))
    end
  end

  namespace :moving_queries do
    desc "initial population of moving_queries data using every date available in daily_queries_stats table. Replaces any existing data in moving_queries table."
    task :populate => :environment do
      min = DailyQueryStat.minimum(:day, :conditions => ['affiliate = ? AND locale = ?', Affiliate::USAGOV_AFFILIATE_NAME, I18n.default_locale.to_s])
      max = DailyQueryStat.maximum(:day, :conditions => ['affiliate = ? AND locale = ?', Affiliate::USAGOV_AFFILIATE_NAME, I18n.default_locale.to_s])
      days = []
      min.upto(max) {|day| days << day.to_s(:number) }
      days.reverse.each { |day| MovingQuery.compute_for(day) }
    end

    desc "compute moving queries for 1-, 7-, and 30-day windows for a given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      MovingQuery.compute_for(args.day)
    end
  end

end