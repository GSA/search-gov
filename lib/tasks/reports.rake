namespace :usasearch do
  namespace :reports do

    def establish_aws_connection
      AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
      AWS::S3::Bucket.find(AWS_BUCKET_NAME) rescue AWS::S3::Bucket.create(AWS_BUCKET_NAME)
    end

    def generate_report_filename(prefix, day, date_format, period)
      "analytics/reports/#{prefix}/#{prefix}_top_queries_#{day.strftime(date_format)}#{period == "weekly" ? "_#{period}" : ""}.csv"
    end

    def generate_report_date_range(period, input_day)
      if period == "monthly"
        query_start_date = input_day.beginning_of_month
        query_end_date = input_day
      elsif period == "weekly"
        query_start_date = input_day
        query_end_date = [input_day + 6.days, Date.yesterday].min
      else
        query_start_date = query_end_date = input_day
      end
      query_start_date..query_end_date
    end

    desc "Generate Top Queries reports (daily, weekly, or monthly) per affiliate on S3 from CTRL-A delimited input file containing affiliate name, query, raw count"
    task :generate_top_queries_from_file, :file_name, :period, :max_entries_per_group, :date, :needs => :environment do |t, args|
      if args.file_name.nil? or args.period.nil? or args.max_entries_per_group.nil?
        Rails.logger.error "usage: rake usasearch:reports:generate_top_queries_from_file[file_name,monthly|weekly|daily,1000]"
      else
        day = args.date.nil? ? Date.yesterday : Date.parse(args.date)
        report_date_range = generate_report_date_range(args.period, day)
        establish_aws_connection
        format = args.period == "monthly" ? '%Y%m' : '%Y%m%d'
        max_entries_per_group = args.max_entries_per_group.to_i
        last_group, cnt, output = nil, 0, nil
        File.open(args.file_name).each do |line|
          affiliate_name, query, total = line.chomp.split(/\001/)
          if last_group.nil? || last_group != affiliate_name
            AWS::S3::S3Object.store(generate_report_filename(last_group, day, format, args.period), output, AWS_BUCKET_NAME) unless output.nil?
            output = "Query,Raw Count,IP-Deduped Count\n"
            cnt = 0
          end
          if cnt < max_entries_per_group
            conditions = ['query=? AND day BETWEEN ? AND ?', query, report_date_range.first, report_date_range.last]
            if affiliate_name != '_all_'
              conditions.first << ' AND affiliate=?'
              conditions << affiliate_name
            end
            daily_query_stats_total = DailyQueryStat.sum(:times, :conditions => conditions)
            output << "#{query},#{total},#{daily_query_stats_total}\n"
            cnt += 1
          end
          last_group = affiliate_name
        end
        AWS::S3::S3Object.store(generate_report_filename(last_group, day, format, args.period), output, AWS_BUCKET_NAME) unless output.nil?
      end
    end
    
    desc "Email users monthly affiliate report"
    task :email_monthly_reports, :report_year_month, :needs => :environment do |t, args|
      report_date = args.report_year_month.blank? ? Date.yesterday : Date.parse(args.report_year_month + "-01")
      User.all.each do |user|
        Emailer.affiliate_monthly_report(user, report_date).deliver
      end
    end
  end
end