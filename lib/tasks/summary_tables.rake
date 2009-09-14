namespace :usasearch do
  namespace :daily_query_ip_stats do
    insert_sql = "insert ignore into daily_query_ip_stats (query, ipaddr, day, times) select lower(query), ipaddr, date(timestamp) day, count(*) from queries "
    where_clause = "where affiliate = 'usasearch.gov' and query not in ( 'cheesewiz' ,'clusty' ,' ', '1', 'test')"
    group_by = "group by day,query, ipaddr"

    desc "initial population of daily_query_ip_stats from queries table. Destroys existing data in daily_query_ip_stats table."
    task :populate => :environment do
      #raise "Usage: rake usasearch:daily_query_ip_stats:populate"
      sql = "truncate daily_query_ip_stats"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{where_clause} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_ip_stats from queries table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      #raise "Usage: rake usasearch:daily_query_ip_stats:compute [YYYYMMDD]"
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
      #raise "Usage: rake usasearch:daily_query_stats:populate"
      sql = "truncate daily_query_stats"
      ActiveRecord::Base.connection.execute(sql)
      calculate_proportions
      sql = "#{insert_sql} #{where_clause} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_stats from queries & daily_queries_ip_stats table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      #raise "Usage: rake usasearch:daily_query_stats:compute [YYYYMMDD]"
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      sql = "delete from daily_query_stats where day = #{yyyymmdd}"
      ActiveRecord::Base.connection.execute(sql)
      calculate_proportions
      sql = "#{insert_sql} #{where_clause} and d.day = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end

  end

  namespace :query_accelerations do
    @min_num_queries_per_window = { 1 => 7, 7=>20, 30 => 50}

    desc "compute 1,7, and 30-day query_accelerations for given YYYYMMDD date (defaults to yesterday)"
    task :compute => :environment do
      #raise "Usage: rake usasearch:query_accelerations:compute [DATE=20090830]"
      sql = "drop table if exists temp_window_counts"
      ActiveRecord::Base.connection.execute(sql)

      day = ENV["DATE"].to_date rescue Date.yesterday
      yyyymmdd = day.to_s(:number).to_i

      sql = "delete from query_accelerations where day = #{yyyymmdd}"
      ActiveRecord::Base.connection.execute(sql)

      calculate_proportions

      score_clause = "(((t1.count-t2.count)/t2.count) + ((t1.count-t3.count)/t3.count) * 0.5 + ((t1.count-t4.count)/t4.count) * 0.3 + ((t2.count-t3.count)/t3.count) * 0.5 + ((t3.count-t4.count)/t4.count) * 0.5) as score "

      [30, 7, 1].each do |window_size|
        from_clause = "from temp_window_counts as t1, temp_window_counts as t2, temp_window_counts as t3, temp_window_counts as t4 where t1.query = t2.query and t1.query = t3.query and t1.query = t4.query and t1.period = 1 and t2.period = 2 and t3.period=3 and t4.period = 4 and t1.count > #{@min_num_queries_per_window[window_size]} having score > 1.0"
        targetdate = day
        sql = "create table temp_window_counts (query varchar(100), period int, count int)"
        ActiveRecord::Base.connection.execute(sql)
        4.times do |idx|
          sql = "insert into temp_window_counts (period, query, count) select #{idx + 1}, query, sum(times) from daily_query_stats where day between #{(targetdate - window_size.days).to_s(:number).to_i} and #{targetdate.to_s(:number).to_i} group by query"
          ActiveRecord::Base.connection.execute(sql)
          targetdate -= window_size.days
        end

        2.upto(4) do |idx|
          sql = "insert into temp_window_counts (period, query, count) select #{idx}, t1.query, 1 from temp_window_counts as t1 where t1.period = 1 and t1.count > #{@min_num_queries_per_window[window_size]} and t1.query not in (select t2.query from temp_window_counts as t2 where period=#{idx})"
          ActiveRecord::Base.connection.execute(sql)
        end

        sql = "insert into query_accelerations (query, day, window_size, score) select t1.query,  #{yyyymmdd}, #{window_size}, #{score_clause} #{from_clause}"
        ActiveRecord::Base.connection.execute(sql)

        sql = "drop table if exists temp_window_counts"
        ActiveRecord::Base.connection.execute(sql)
      end
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