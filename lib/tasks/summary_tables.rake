namespace :usasearch do
  namespace :daily_query_ip_stats do
    insert_sql = "INSERT IGNORE INTO daily_query_ip_stats (query, ipaddr, day, affiliate, locale, times) SELECT lower(query), ipaddr, date(timestamp) day, affiliate, locale, count(*) FROM queries "
    where_clause = "WHERE query NOT IN ( 'enter keywords', 'cheesewiz' , 'cheeseman', 'clusty' ,' ', '1', 'test') AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND (is_bot=false OR ISNULL(is_bot)) AND is_contextual=false"
    affiliate_where_clause = "WHERE query NOT IN ( 'enter keywords', 'cheesewiz' , 'cheeseman', 'clusty' ,' ', '1', 'test') AND ipaddr NOT IN ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') AND (is_bot=false OR ISNULL(is_bot)) AND affiliate<>'usasearch.gov' AND is_contextual=false"    
    group_by = "GROUP BY day, query, ipaddr, affiliate, locale"

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
      sql = "DELETE FROM daily_query_ip_stats WHERE day = #{yyyymmdd}"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{where_clause} AND date(timestamp) = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end
    
    desc "compute daily_query_ip_stats from queries table for given YYYYMMDD date (defaults to yesterday) for affiliates only"
    task :compute_affiliates, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      sql = "DELETE FROM daily_query_ip_stats WHERE day = #{yyyymmdd} AND affiliate <> 'usasearch.gov'"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{affiliate_where_clause} AND date(timestamp) = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end   
  end
  
  namespace :daily_query_stats do
    insert_sql = "INSERT INTO daily_query_stats (query, day, times, affiliate, locale) SELECT d.query, d.day, count(*), d.affiliate, d.locale FROM daily_query_ip_stats d, proportions p"
    affiliate_insert_sql = "INSERT INTO daily_query_stats (query, day, times, affiliate, locale) SELECT d.query, d.day, count(*), d.affiliate, d.locale FROM daily_query_ip_stats d, affiliate_proportions p"
    where_clause = "WHERE d.query = p.query AND p.proportion > 0.10 AND d.affiliate=p.affiliate AND d.locale=p.locale"
    affiliate_where_clause = "WHERE d.query = p.query AND p.proportion > 0.10 and d.affiliate=p.affiliate AND p.affiliate<>'usasearch.gov' AND d.locale=p.locale"
    group_by = "GROUP BY d.query, d.day, d.affiliate, d.locale"

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

    desc "compute daily_query_stats from queries & daily_queries_ip_stats table for given YYYYMMDD date (defaults to yesterday) for affiliates"
    task :compute_affiliates, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      sql = "delete from daily_query_stats where day = #{yyyymmdd} AND affiliate<>'usasearch.gov'"
      ActiveRecord::Base.connection.execute(sql)
      calculate_affiliate_proportions
      sql = "#{affiliate_insert_sql} #{affiliate_where_clause} and d.day = #{yyyymmdd} #{group_by}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  namespace :moving_queries do
    desc "initial population of moving_queries data using every date available in daily_queries_stats table. Replaces any existing data in moving_queries table."
    task :populate => :environment do
      min = DailyQueryStat.minimum(:day, :conditions => ['affiliate = ? AND locale = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME, I18n.default_locale.to_s])
      max = DailyQueryStat.maximum(:day, :conditions => ['affiliate = ? AND locale = ?', DailyQueryStat::DEFAULT_AFFILIATE_NAME, I18n.default_locale.to_s])
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
    sql = "CREATE TEMPORARY TABLE proportions(query varchar(100), affiliate varchar(32), locale varchar(5), times int, uips int, proportion float) SELECT query, affiliate, locale, sum(times) as times, count(distinct ipaddr) as uips, count(distinct ipaddr)/sum(times) proportion FROM daily_query_ip_stats GROUP BY affiliate, locale, query HAVING times > 10"
    ActiveRecord::Base.connection.execute(sql)
    sql = "ALTER TABLE proportions ADD INDEX qp (query, proportion)"
    ActiveRecord::Base.connection.execute(sql)
  end

  def calculate_affiliate_proportions
    sql = "DROP TABLE IF EXISTS affiliate_proportions"
    ActiveRecord::Base.connection.execute(sql)
    sql = "CREATE TEMPORARY TABLE affiliate_proportions(query varchar(100), affiliate varchar(32), locale varchar(5), times int, uips int, proportion float) SELECT query, affiliate, locale, sum(times) as times, count(distinct ipaddr) as uips, count(distinct ipaddr)/sum(times) proportion FROM daily_query_ip_stats GROUP BY affiliate, locale, query HAVING times > 10"
    ActiveRecord::Base.connection.execute(sql)
    sql = "ALTER TABLE affiliate_proportions ADD INDEX qp (query, proportion)"
    ActiveRecord::Base.connection.execute(sql)
  end
end