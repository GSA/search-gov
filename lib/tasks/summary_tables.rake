namespace :usasearch do

  namespace :moving_queries do
    desc "initial population of moving_queries data using every date available in daily_queries_stats table. Replaces any existing data in moving_queries table."
    task :populate => :environment do
      conditions = ['affiliate = ? AND locale = ?', Affiliate::USAGOV_AFFILIATE_NAME, I18n.default_locale.to_s]
      min = DailyQueryStat.minimum(:day, :conditions => conditions)
      max = DailyQueryStat.maximum(:day, :conditions => conditions)
      days = []
      min.upto(max) { |day| days << day.to_s(:number) }
      days.reverse.each { |day| MovingQuery.compute_for(day) }
    end

    desc "compute moving queries for 1-, 7-, and 30-day windows for a given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      MovingQuery.compute_for(args.day)
    end
  end

  namespace :daily_popular_queries do
    desc "Total up the most popular queries and query groups for the given date range (defaults to yesterday)"
    task :calculate, :start_day, :end_day, :needs => :environment do |t, args|
      args.with_defaults(:start_day => Date.yesterday.to_s(:number), :end_day => Date.yesterday.to_s(:number))
      start_date, end_date = Date.parse(args.start_day), Date.parse(args.end_day)
      combinations = [{:method => :most_popular_terms, :is_grouped => false}, {:method => :most_popular_query_groups, :is_grouped => true}]
      start_date.upto(end_date) do |day|
        [1, 7, 30].each do |time_frame|
          combinations.each do |combo|
            DailyPopularQuery.calculate(day, time_frame, combo[:method], combo[:is_grouped])
          end
        end
      end
    end
  end

  namespace :monthly_popular_queries do
    desc "Total up the most popular queries and query groups for the month of the given day (defaults to yesterday)"
    task :calculate, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      combinations = [{:method => :most_popular_terms_for_year_month, :is_grouped => false}, {:method => :most_popular_groups_for_year_month, :is_grouped => true}]
      MonthlyPopularQuery.delete_all(["year = ? and month = ?", day.year, day.month])
      combinations.each do |combo|
        query_counts = DailyQueryStat.send(combo[:method], day.year, day.month, 1000)
        query_counts.each do |query_count|
          MonthlyPopularQuery.create!(:year => day.year, :month => day.month, :query => query_count.query, :is_grouped => combo[:is_grouped], :times => query_count.times)
        end unless query_counts.is_a?(String)
      end
    end
  end
end