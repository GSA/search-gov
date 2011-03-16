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
  
  namespace :monthly_popular_queries do
    desc "Total up the most popular queries for the month of the previous day"
    task :calculate_monthly_popular_queries, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      popular_terms = DailyQueryStat.most_popular_terms_for_year_month(day.year, day.month, 1000)
      popular_terms.each do |popular_term|
        monthly_popular_query = MonthlyPopularQuery.find_or_create_by_year_and_month_and_query(day.year, day.month, popular_term.query)
        monthly_popular_query.update_attributes(:times => popular_term.times, :is_grouped => popular_term.is_grouped)
      end unless popular_terms.is_a?(String)
    end
  end
end