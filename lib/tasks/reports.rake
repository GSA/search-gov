namespace :usasearch do
  namespace :reports do

    def establish_aws_connection
      AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
      AWS::S3::Bucket.find(AWS_BUCKET_NAME) rescue AWS::S3::Bucket.create(AWS_BUCKET_NAME)
    end

    def generate_report_filename(prefix, day, date_format)
      "analytics/reports/#{prefix}/#{prefix}_top_queries_#{day.strftime(date_format)}.csv"
    end

    desc "Generate Top Queries reports (daily or monthly) on S3 from CTRL-A delimited input file containing group(e.g., affiliate or locale), query, total"
    task :generate_top_queries_from_file, :file_name, :period, :max_entries_per_group, :date, :needs => :environment do |t, args|
      if args.file_name.nil? or args.period.nil? or args.max_entries_per_group.nil?
        Rails.logger.error "usage: rake usasearch:reports:generate_top_queries_from_file[file_name,monthly|daily,1000]"
      else
        day = args.date.nil? ? Date.yesterday : Date.parse(args.date)
        establish_aws_connection
        format = args.period == "monthly" ? '%Y%m' : '%Y%m%d'
        max_entries_per_group = args.max_entries_per_group.to_i
        last_group, cnt, output = nil, 0, nil
        File.open(args.file_name).each do |line|
          group, query, total = line.chomp.split(/\001/)
          if last_group.nil? || last_group != group
            AWS::S3::S3Object.store(generate_report_filename(last_group, day, format), output, AWS_BUCKET_NAME) unless output.nil?
            output = "Query,Count\n"
            cnt = 0;
          end
          if cnt < max_entries_per_group
            output << "#{query},#{total}\n"
            cnt += 1
          end
          last_group = group
        end
        AWS::S3::S3Object.store(generate_report_filename(last_group, day, format), output, AWS_BUCKET_NAME) unless output.nil?
      end
    end
    
    def output_to_zipfile(zip_filename, filename, header_row, rows)
      Zip::ZipFile.open(zip_filename, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.get_output_stream(filename) do |file|
          file.puts header_row
          rows.each do |row|
            file.puts row
          end
        end
      end
    end
    
    desc "Output dates for reprocessing the logs before running monthly reports"
    task :reprocess_dates => :environment do
      end_date = Date.current.beginning_of_month - 1.day
      start_date = end_date.beginning_of_month
      Kernel.puts "#{start_date.strftime('%Y%m%d')} #{end_date.strftime('%Y%m%d')}"
    end
    
    desc "Generate affiliate report on a weekly basis and email to admins"
    task :weekly_report, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      start_date = Date.parse(args.day).beginning_of_week
      end_date = Date.parse(args.day).end_of_week
      
      zip_filename = "/tmp/weekly_report_#{start_date.strftime('%Y-%m-%d')}.zip"
      
      # affiliate report
      affiliate_report_sql = "SELECT DISTINCT affiliate, total_queries FROM daily_usage_stats WHERE NOT ISNULL(affiliate) AND day BETWEEN ? AND ? GROUP BY affiliate ORDER BY 2 DESC"
      affiliate_report = Affiliate.find_by_sql [affiliate_report_sql, start_date, end_date]
      output_to_zipfile(zip_filename, "affiliate_report.txt","Name,TotalQueries", affiliate_report.collect{|result| "#{result.affiliate},#{result.total_queries}"})
      
      Emailer.deliver_report(zip_filename, start_date, "Weekly Report data attached")
    
      File.delete(zip_filename)
    end
    
    desc "Generate various data outputs for a month and email to admins"
    task :monthly_report, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => (Date.current.beginning_of_month - 1.day).to_s(:number))
      start_date = Date.parse(args.day).beginning_of_month
      end_date = Date.parse(args.day).end_of_month + 1.day
      
      zip_filename = "/tmp/monthly_report_#{start_date.strftime('%Y-%m')}.zip"
        
      # top monthly query groups
      top_monthy_query_groups_sql = "select q.name, sum(d.times) cnt from daily_query_stats d, query_groups q, grouped_queries g, grouped_queries_query_groups b where day between ? AND ? AND affiliate = 'usasearch.gov' AND locale = ? and d.query = g.query and q.id = b.query_group_id and g.id = b.grouped_query_id group by q.name order by cnt desc limit 50"
      top_monthly_query_groups_en = DailyQueryStat.find_by_sql [top_monthy_query_groups_sql, start_date, end_date, "en"]
      top_monthly_query_groups_es = DailyQueryStat.find_by_sql [top_monthy_query_groups_sql, start_date, end_date, "es"]
      top_monthly_query_groups_affiliates = DailyQueryStat.find_by_sql ["select q.name, sum(d.times) cnt from daily_query_stats d, query_groups q, grouped_queries g, grouped_queries_query_groups b where day between ? AND ? AND affiliate != 'usasearch.gov' and d.query = g.query and q.id = b.query_group_id and g.id = b.grouped_query_id group by q.name order by cnt desc limit 50", start_date, end_date]
      output_to_zipfile(zip_filename, "top_monthly_query_groups_en.txt", "Name,Count", top_monthly_query_groups_en.collect{|result| "#{result.name},#{result.cnt}"})
      output_to_zipfile(zip_filename, "top_monthly_query_groups_es.txt", "Name,Count", top_monthly_query_groups_es.collect{|result| "#{result.name},#{result.cnt}"})
      output_to_zipfile(zip_filename, "top_monthly_query_groups_affiliates.txt", "Name,Count", top_monthly_query_groups_affiliates.collect{|result| "#{result.name},#{result.cnt}"})
        
      # top monthly queries
      top_monthly_queries_sql = "SELECT query, sum(`daily_query_stats`.times) AS cnt FROM `daily_query_stats` FORCE INDEX (aldq) WHERE (day between ? AND ? AND affiliate = 'usasearch.gov' AND locale = ?) GROUP BY query ORDER BY cnt desc LIMIT 50"
      top_monthly_queries_en = DailyQueryStat.find_by_sql [top_monthly_queries_sql, start_date, end_date, "en"]
      top_monthly_queries_es = DailyQueryStat.find_by_sql [top_monthly_queries_sql, start_date, end_date, "es"]
      top_monthly_queries_affiliates = DailyQueryStat.find_by_sql ["SELECT query, sum(`daily_query_stats`.times) AS cnt FROM `daily_query_stats` FORCE INDEX (aldq) WHERE (day between ? AND ? AND affiliate != 'usasearch.gov' ) GROUP BY query  ORDER BY cnt desc LIMIT 50", start_date, end_date]
    output_to_zipfile(zip_filename, "top_monthly_queries_en.txt", "Query,Count", top_monthly_queries_en.collect{|result| "#{result.query},#{result.cnt}"})
    output_to_zipfile(zip_filename, "top_monthly_queries_es.txt", "Query,Count", top_monthly_queries_es.collect{|result| "#{result.query},#{result.cnt}"})
    output_to_zipfile(zip_filename, "top_monthly_queries_affiliates.txt", "Query,Count", top_monthly_queries_affiliates.collect{|result| "#{result.query},#{result.cnt}"})
        
      
    # top affiliates
    top_affiliates = Affiliate.find_by_sql ["SELECT affiliate, sum(`daily_query_stats`.times) AS cnt FROM `daily_query_stats` WHERE day between ? AND ? GROUP BY affiliate ORDER BY cnt desc LIMIT 50", start_date, end_date]
    output_to_zipfile(zip_filename, "top_affiliates.txt", "Name,Count", top_affiliates.collect{|result| "#{result.affiliate},#{result.cnt}"})
    
    # affiliate queries for the past five months
    months = 4.downto(0).collect{|index| (start_date - index.months).strftime('%Y-%m')} 
    months_cases_sql = months.collect{|month| "SUM( CASE month WHEN '#{month}' THEN cnt ELSE 0 END ) AS '#{month}'"}.join(",")
    affiliate_queries_by_month_sql = "SELECT affiliate, #{months_cases_sql}, SUM( cnt ) AS Total FROM ( SELECT affiliate, left(day, 7) month, sum(`daily_query_stats`.times) AS cnt FROM `daily_query_stats` WHERE day between ? and ? GROUP BY affiliate, month having cnt > 50000 ) AS stats  GROUP BY affiliate WITH ROLLUP"
    affiliate_queries_by_month = Affiliate.find_by_sql [affiliate_queries_by_month_sql, (start_date - 4.months).beginning_of_month, end_date]
    output_to_zipfile(zip_filename, "affiliate_queries_by_month.txt", "Affiliate,#{months.join(",")},Total", affiliate_queries_by_month.collect{|result| "#{result.affiliate},#{months.collect{|month| result[month]}.join(',')}"})
      
    # clicks by module over the past month
    click_totals = MonthlyClickTotal.find_all_by_year_and_month(start_date.year, start_date.month)
    output_to_zipfile(zip_filename, "click_totals.txt", "Module,Total", click_totals.collect{|result| "#{result.source},#{result.total}"})
  
    # affiliate report
    affiliate_report_sql = "SELECT DISTINCT affiliate, total_queries FROM daily_usage_stats WHERE NOT ISNULL(affiliate) AND day BETWEEN ? AND ? GROUP BY affiliate ORDER BY 2 DESC"
    affiliate_report = Affiliate.find_by_sql [affiliate_report_sql, start_date, end_date]
    output_to_zipfile(zip_filename, "affiliate_report.txt","Name,TotalQueries", affiliate_report.collect{|result| "#{result.affiliate},#{result.total_queries}"})
    
    # total queries by profile
    monthly_totals = DailyUsageStat.monthly_totals(start_date.year, start_date.month)
    output = "#{start_date.strftime('%Y-%m')},#{monthly_totals['English'][:total_queries]},#{monthly_totals['Spanish'][:total_queries]},#{monthly_totals['Affiliates'][:total_queries]},#{monthly_totals['English'][:total_queries]+monthly_totals['Spanish'][:total_queries]+monthly_totals['Affiliates'][:total_queries]}"
    output_to_zipfile(zip_filename, "total_queries_by_profile.txt", "Month,English,Spanish,Affilitates,Total", output)
    
    Emailer.deliver_report(zip_filename, start_date, "Monthly Report data attached")
    
    File.delete(zip_filename)
    end
  end
end