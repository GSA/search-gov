namespace :usasearch do
  namespace :daily_query_ip_stats do

    desc "initial population of daily_query_ip_stats from queries table. Destroys existing data in daily_query_ip_stats table."
    task :populate_daily_query_ip_stats => :environment do
      #raise "Usage: rake usasearch:daily_query_ip_stats:populate_daily_query_ip_stats"
      puts "Creating daily query IP stats..."
      sql = "truncate daily_query_ip_stats"
      ActiveRecord::Base.connection.execute(sql)
      sql = "insert ignore into daily_query_ip_stats (query, ipaddr, day, times) select query, ipaddr, date(timestamp) day, count(*) from queries where affiliate = 'usasearch.gov' and query not in ( 'cheesewiz' ,'clusty' ,' ', '1', 'test') group by day,query, ipaddr"
      ActiveRecord::Base.connection.execute(sql)
    end

  end

  namespace :query_accelerations do

    desc "compute 1,7, and 30-day query_accelerations for given YYYYMMDD date (defaults to yesterday)"
    task :compute => :environment do
      #raise "Usage: rake usasearch:query_accelerations:compute [DATE=20090830]"
      day = ENV["DATE"].to_date rescue Date.yesterday
      sql = "create temporary table proportions(query varchar(100), times int, uips int, proportion float) select query, sum(times) as times, count( ipaddr) as uips, count( ipaddr)/sum(times) proportion from daily_query_ip_stats  group by query having times > 10"
      ActiveRecord::Base.connection.execute(sql)

      score_clause = "(((t1.count-t2.count)/t2.count) + ((t1.count-t3.count)/t3.count) * 0.5 + ((t1.count-t4.count)/t4.count) * 0.3 + ((t2.count-t3.count)/t3.count) * 0.5 + ((t3.count-t4.count)/t4.count) * 0.5) as score "
      from_clause = "from temp_window_counts as t1, temp_window_counts as t2, temp_window_counts as t3, temp_window_counts as t4 where t1.query = t2.query and t1.query = t3.query and t1.query = t4.query and t1.period = 1 and t2.period = 2 and t3.period=3 and t4.period = 4 and t1.count > 50 having score > 1.0"

      [1, 7, 30].each do |window_size|
        targetdate = day
        #make temp table of N day counts
        sql = "create table temp_window_counts (query varchar(100), period int, count int)"
        ActiveRecord::Base.connection.execute(sql)
        4.times do |idx|
          sql = "insert into temp_window_counts (period, query, count) select #{idx}, query, sum(times) from daily_query_stats where day between date_sub(#{targetdate}, interval #{window_size} day) and #{targetdate} group by query"
          ActiveRecord::Base.connection.execute(sql)
          targetdate = targetdate - window_size.days
        end

        # compute accelerations
        sql = "insert into query_accelerations (query, day, window_size, score) select t1.query,  #{day}, #{window_size}, #{score_clause} #{from_clause}"
        ActiveRecord::Base.connection.execute(sql)

        sql = "drop table temp_window_counts"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end