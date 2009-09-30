namespace :usasearch do
  namespace :daily_query_ip_stats do
    insert_sql = "insert ignore into daily_query_ip_stats (query, ipaddr, day, times) select lower(query), ipaddr, date(timestamp) day, count(*) from queries "
    where_clause = "where affiliate = 'usasearch.gov' and query not in ( 'enter keywords', 'cheesewiz' ,'clusty' ,' ', '1', 'test') and ipaddr not in ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') "
    group_by = "group by day,query, ipaddr"

    desc "initial population of daily_query_ip_stats from queries table. Destroys existing data in daily_query_ip_stats table."
    task :populate => :environment do
      sql = "truncate daily_query_ip_stats"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{where_clause} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_ip_stats from queries table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      sql = "delete from daily_query_ip_stats where day = #{yyyymmdd}"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{where_clause} and date(timestamp) = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

  end

  namespace :daily_query_stats do
    insert_sql = "insert into daily_query_stats (query, day,times) select d.query, d.day, count(*) from daily_query_ip_stats  d, proportions p"
    where_clause = "where d.query = p.query and p.proportion > .10"
    group_by = "group by d.query, d.day"

    desc "initial population of daily_query_stats from queries & daily_queries_ip_stats table. Destroys existing data in daily_query_stats table."
    task :populate => :environment do
      sql = "truncate daily_query_stats"
      ActiveRecord::Base.connection.execute(sql)
      calculate_proportions
      sql = "#{insert_sql} #{where_clause} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_stats from queries & daily_queries_ip_stats table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      sql = "delete from daily_query_stats where day = #{yyyymmdd}"
      ActiveRecord::Base.connection.execute(sql)
      calculate_proportions
      sql = "#{insert_sql} #{where_clause} and d.day = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  namespace :moving_queries do
    desc "initial population of moving_queries data using every date available in daily_queries_stats table. Replaces any existing data in moving_queries table."
    task :populate => :environment do
      min = DailyQueryStat.minimum(:day)
      max = DailyQueryStat.maximum(:day)
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

  private
  def calculate_proportions
    sql = "drop table if exists proportions"
    ActiveRecord::Base.connection.execute(sql)
    sql = "create temporary table proportions(query varchar(100), times int, uips int, proportion float) select query, sum(times) as times, count( distinct ipaddr) as uips, count( distinct ipaddr)/sum(times) proportion from daily_query_ip_stats  group by query having times > 10"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table proportions add index qp (query, proportion)"
    ActiveRecord::Base.connection.execute(sql)
  end
end