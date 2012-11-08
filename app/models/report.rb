class Report
  def initialize(file_name, period, group_max, day)
    @file_name, @period, @group_max, @day = file_name, period, group_max, day
  end

  def establish_aws_connection
    AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
    AWS::S3::Bucket.find(AWS_BUCKET_NAME) rescue AWS::S3::Bucket.create(AWS_BUCKET_NAME)
  end

  def generate_report_filename(prefix, formatted_date)
    "analytics/reports/#{prefix}/#{prefix}_top_queries_#{formatted_date}#{'_weekly' if @period == 'weekly'}.csv"
  end

  def generate_report_date_range
    query_start_date = query_end_date = @day
    if @period == "monthly"
      query_start_date = @day.beginning_of_month
      query_end_date = @day
    elsif @period == "weekly"
      query_start_date = @day
      query_end_date = [@day + 6.days, Date.yesterday].min
    end
    query_start_date..query_end_date
  end
  
  def day_formatted_for_period
    date_format = @period == "monthly" ? '%Y%m' : '%Y%m%d'
    @day.strftime(date_format)    
  end

  def generate_top_queries_from_file
    report_date_range = generate_report_date_range
    establish_aws_connection
    formatted_date = day_formatted_for_period
    last_group, cnt, output = nil, 0, nil
    File.open(@file_name).each do |line|
      begin
        affiliate_name, query, total = line.chomp.split(/\001/)
        if last_group.nil? || last_group != affiliate_name
          AWS::S3::S3Object.store(generate_report_filename(last_group, formatted_date), output, AWS_BUCKET_NAME) unless output.nil?
          output = "Query,Raw Count,IP-Deduped Count\n"
          cnt = 0
        end
        if cnt < @group_max
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
      rescue Exception => e
        Rails.logger.warn "Trouble with an input line so skipping it: #{e.message}"
      end
    end
    AWS::S3::S3Object.store(generate_report_filename(last_group, formatted_date), output, AWS_BUCKET_NAME) unless output.nil?
  end
end