namespace :usasearch do
  namespace :daily_query_ip_stats do
    insert_sql = "INSERT IGNORE INTO daily_query_ip_stats (query, ipaddr, day, affiliate, times) SELECT lower(query), ipaddr, date(timestamp) day, affiliate, count(*) FROM queries "
    where_clause = "WHERE query NOT IN ( 'enter keywords', 'cheesewiz' ,'clusty' ,' ', '1', 'test') AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND (is_bot=false OR ISNULL(is_bot))"
    group_by = "GROUP BY day, query, ipaddr, affiliate"

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
      sql = "#{insert_sql} #{where_clause} AND date(timestamp) = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end    
  end

  namespace :daily_query_stats do
    insert_sql = "INSERT INTO daily_query_stats (query, day, times, affiliate) SELECT d.query, d.day, count(*), d.affiliate FROM daily_query_ip_stats d, proportions p"
    where_clause = "WHERE d.query = p.query AND p.proportion > 0.10"
    group_by = "GROUP BY d.query, d.day, d.affiliate"

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
      min = DailyQueryStat.minimum(:day, :conditions => ['affiliate = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME])
      max = DailyQueryStat.maximum(:day, :conditions => ['affiliate = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME])
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
    sql = "DROP TABLE IF EXISTS proportions"
    ActiveRecord::Base.connection.execute(sql)
    sql = "CREATE TEMPORARY TABLE proportions(query varchar(100), affiliate varchar(32), times int, uips int, proportion float) SELECT query, affiliate, sum(times) as times, count(distinct ipaddr) as uips, count(distinct ipaddr)/sum(times) proportion FROM daily_query_ip_stats GROUP BY affiliate, query HAVING times > 10"
    ActiveRecord::Base.connection.execute(sql)
    sql = "ALTER TABLE proportions ADD INDEX qp (query, proportion)"
    ActiveRecord::Base.connection.execute(sql)
  end
end