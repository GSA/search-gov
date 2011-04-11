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
  
  namespace :daily_popular_queries do
    desc "Total up the most popular queries for the previous day"
    task :calculate, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      time_frames = [1, 7, 30]
      time_frames.each do |time_frame|
        popular_queries = DailyQueryStat.most_popular_terms(day, time_frame, 1000)
        popular_queries.each do |popular_query|
          daily_popular_query = DailyPopularQuery.find_or_create_by_day_and_affiliate_and_locale_and_query_and_is_grouped_and_time_frame(day, nil, 'en', popular_query.query, false, time_frame)
          daily_popular_query.update_attributes(:times => popular_query.times)
        end unless popular_queries.is_a?(String)
        popular_query_groups = DailyQueryStat.most_popular_query_groups(day, time_frame, 1000)
        popular_query_groups.each do |popular_query_group|
          daily_popular_query_group = DailyPopularQuery.find_or_create_by_day_and_affiliate_and_locale_and_query_and_is_grouped_and_time_frame(day, nil, 'en', popular_query_group.query, true, time_frame)
          daily_popular_query_group.update_attributes(:times => popular_query_group.times)
        end unless popular_query_groups.is_a?(String)
      end
    end
  end
  
  namespace :monthly_popular_queries do
    desc "Total up the most popular queries for the month of the previous day"
    task :calculate, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      popular_terms = DailyQueryStat.most_popular_terms_for_year_month(day.year, day.month, 1000)
      popular_terms.each do |popular_term|
        monthly_popular_query = MonthlyPopularQuery.find_or_create_by_year_and_month_and_query_and_is_grouped(day.year, day.month, popular_term.query, false)
        monthly_popular_query.update_attributes(:times => popular_term.times)
      end unless popular_terms.is_a?(String)
      popular_groups = DailyQueryStat.most_popular_groups_for_year_month(day.year, day.month, 1000)
      popular_groups.each do |popular_group|
        monthly_popular_group = MonthlyPopularQuery.find_or_create_by_year_and_month_and_query_and_is_grouped(day.year, day.month, popular_group.query, true)
        monthly_popular_group.update_attributes(:times => popular_group.times)
      end unless popular_groups.is_a?(String)
      click_totals = Click.monthly_totals_by_module(day.year, day.month)
      click_totals.each_pair do |source, total|
        monthly_click_total = MonthlyClickTotal.find_or_create_by_year_and_month_and_source(day.year, day.month, source)
        monthly_click_total.update_attributes(:total => total)
      end
    end
  end
end