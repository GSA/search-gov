namespace :usasearch do
  namespace :daily_query_ip_stats do
    insert_sql = "insert ignore into daily_query_ip_stats (query, ipaddr, day, times) select lower(query), ipaddr, date(timestamp) day, count(*) from queries "
    where_clause = "where affiliate = 'usasearch.gov' and query not in ( 'cheesewiz' ,'clusty' ,' ', '1', 'test')"
    group_by = "group by day,query, ipaddr"

    desc "initial population of daily_query_ip_stats from queries table. Destroys existing data in daily_query_ip_stats table."
    task :populate => :environment do
      #raise "Usage: rake usasearch:daily_query_ip_stats:populate"
      puts "Creating daily query IP stats..."
      sql = "truncate daily_query_ip_stats"
      ActiveRecord::Base.connection.execute(sql)
      sql = "#{insert_sql} #{where_clause} #{group_by}"
      puts sql
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_ip_stats from queries table for given YYYYMMDD date (defaults to yesterday)"
    task :compute => :environment do
      #raise "Usage: rake usasearch:daily_query_ip_stats:compute [DATE=20090830]"
      day = ENV["DATE"].to_date rescue Date.yesterday
      puts "Creating daily query IP stats for #{day}..."
      sql = "#{insert_sql} #{where_clause} and date(timestamp) = #{day.to_s(:number).to_i} #{group_by}"
      puts sql
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
      puts "Creating daily query stats..."
      sql = "truncate daily_query_stats"
      ActiveRecord::Base.connection.execute(sql)

      calculate_proportions

      sql = "#{insert_sql} #{where_clause} #{group_by}"
      puts sql
      ActiveRecord::Base.connection.execute(sql)
    end

    desc "compute daily_query_stats from queries & daily_queries_ip_stats table for given YYYYMMDD date (defaults to yesterday)"
    task :compute => :environment do
      #raise "Usage: rake usasearch:daily_query_stats:compute [DATE=20090830]"
      day = ENV["DATE"].to_date rescue Date.yesterday
      puts "Creating daily query stats for day #{day}..."

      calculate_proportions

      sql = "#{insert_sql} #{where_clause} and d.day = #{day.to_s(:number).to_i} #{group_by}"
      puts sql
      ActiveRecord::Base.connection.execute(sql)
    end

  end

  namespace :query_accelerations do

    desc "compute 1,7, and 30-day query_accelerations for given YYYYMMDD date (defaults to yesterday)"
    task :compute => :environment do
      #raise "Usage: rake usasearch:query_accelerations:compute [DATE=20090830]"
      sql = "drop table if exists temp_window_counts"
      ActiveRecord::Base.connection.execute(sql)

      day = ENV["DATE"].to_date rescue Date.yesterday
      sql = "delete from query_accelerations where day = #{day.to_s(:number).to_i}"
      ActiveRecord::Base.connection.execute(sql)

      calculate_proportions

      score_clause = "(((t1.count-t2.count)/t2.count) + ((t1.count-t3.count)/t3.count) * 0.5 + ((t1.count-t4.count)/t4.count) * 0.3 + ((t2.count-t3.count)/t3.count) * 0.5 + ((t3.count-t4.count)/t4.count) * 0.5) as score "
      from_clause = "from temp_window_counts as t1, temp_window_counts as t2, temp_window_counts as t3, temp_window_counts as t4 where t1.query = t2.query and t1.query = t3.query and t1.query = t4.query and t1.period = 1 and t2.period = 2 and t3.period=3 and t4.period = 4 and t1.count > 50"

      [30, 7, 1].each do |window_size|
        targetdate = day
        puts "Creating #{window_size}-day windows..."
        sql = "create table temp_window_counts (query varchar(100), period int, count int)"
        puts sql
        ActiveRecord::Base.connection.execute(sql)
        4.times do |idx|
          sql = "insert into temp_window_counts (period, query, count) select #{idx + 1}, query, sum(times) from daily_query_stats where day between #{(targetdate - window_size.days).to_s(:number).to_i} and #{targetdate.to_s(:number).to_i} group by query"
          puts sql
          ActiveRecord::Base.connection.execute(sql)
          targetdate -= window_size.days
        end

        puts "Inserting into query_calculations..."
        sql = "insert into query_accelerations (query, day, window_size, score) select t1.query,  #{day.to_s(:number).to_i}, #{window_size}, #{score_clause} #{from_clause}"
        puts sql
        ActiveRecord::Base.connection.execute(sql)

        sql = "drop table if exists temp_window_counts"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end

  private
  def calculate_proportions
    puts "Calculating proportions..."
    sql = "create temporary table proportions(query varchar(100), times int, uips int, proportion float) select query, sum(times) as times, count( ipaddr) as uips, count( ipaddr)/sum(times) proportion from daily_query_ip_stats  group by query having times > 10"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table proportions add index qp (query, proportion)"
    ActiveRecord::Base.connection.execute(sql)
  end
end