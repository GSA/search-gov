namespace :usasearch do

  namespace :moving_queries do
    desc "initial population of moving_queries data using every date available (most recent first) in daily_queries_stats table. Replaces any existing data in moving_queries table."
    task :populate => :environment do
      DailyQueryStat.available_dates_range.to_a.reverse.each { |day| MovingQuery.compute_for(day.to_s(:number)) }
    end

    desc "compute moving queries for a given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      MovingQuery.compute_for(args.day)
    end
  end

  namespace :daily_popular_query_groups do
    desc "Total up the most popular query groups for the given date range (defaults to yesterday)"
    task :calculate, :start_day, :end_day, :needs => :environment do |t, args|
      args.with_defaults(:start_day => Date.yesterday.to_s(:number), :end_day => Date.yesterday.to_s(:number))
      Date.parse(args.start_day).upto(Date.parse(args.end_day)) do |day|
        [1, 7, 30].each { |time_frame| DailyPopularQueryGroup.calculate(day, time_frame) }
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