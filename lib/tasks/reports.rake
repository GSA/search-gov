namespace :usasearch do
  namespace :reports do

    def establish_aws_connection
      AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
      AWS::S3::Bucket.find(AWS_BUCKET_NAME) rescue AWS::S3::Bucket.create(AWS_BUCKET_NAME)
    end

    def generate_report_filename(prefix, day, date_format)
      "reports/#{prefix}_top_queries_#{day.strftime(date_format)}.csv"
    end

    def generate_report(top_queries, filename)
      csv_string = FasterCSV.generate do |csv|
        csv << ["Query", "Count"]
        top_queries.each do |top_query|
          csv << [top_query.query, top_query.total]
        end
      end
      AWS::S3::S3Object.store(filename, csv_string, AWS_BUCKET_NAME)
    end

    def production_affiliate_names
      affiliates_file = '/tmp/affiliates.out'
      affiliate_names = []
      File.open(affiliates_file).each_with_index do |line, index|
        unless index == 0
          affiliate_names << line.chomp
        end
      end if File.exist?(affiliates_file)
      affiliate_names
    end

    desc "Generate Top Queries reports (daily or monthly) on S3 from CTRL-A delimited input file containing group(e.g., affiliate or locale), query, total"
    task :generate_top_queries_from_file, :file_name, :period, :max_entries_per_group, :needs => :environment do |t, args|
      if args.file_name.nil? or args.period.nil? or args.max_entries_per_group.nil?
        RAILS_DEFAULT_LOGGER.error "usage: rake usasearch:reports:generate_top_queries_from_file[file_name,monthly|daily,1000]"
      else
        establish_aws_connection
        format = args.period == "monthly" ? '%Y%m' : '%Y%m%d'
        max_entries_per_group = args.max_entries_per_group.to_i
        last_group, cnt, output = nil, 0, nil
        File.open(args.file_name).each do |line|
          group, query, total = line.chomp.split(/\001/)
          if last_group.nil? || last_group != group
            AWS::S3::S3Object.store(generate_report_filename(last_group, Date.yesterday, format), output, AWS_BUCKET_NAME) unless output.nil?
            output = "Query,Count\n"
            cnt = 0;
          end
          if cnt < max_entries_per_group
            output << "#{query},#{total}\n"
            cnt += 1
          end
          last_group = group
        end
        AWS::S3::S3Object.store(generate_report_filename(last_group, Date.yesterday, format), output, AWS_BUCKET_NAME) unless output.nil?
      end
    end

    desc "Generate Top Queries reports for the month of the date specified"
    task :generate_monthly_top_queries, :day, :generate_usasearch, :generate_affiliates, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number), :generate_usasearch => "true", :generate_affiliates => "true")
      day = Date.parse(args.day)
      establish_aws_connection
      %w{en es}.each do |locale|
        top_queries = Query.top_queries(day.beginning_of_month.beginning_of_day, day.end_of_month.end_of_day, locale, 'usasearch.gov', locale == 'en' ? 30000: 4000, true)
        generate_report(top_queries, generate_report_filename(locale, day, '%Y%m'))
      end if args.generate_usasearch
      production_affiliate_names.each do |affiliate_name|
        top_queries = Query.top_queries(day.beginning_of_month.beginning_of_day, day.end_of_month.end_of_day, I18n.default_locale.to_s, affiliate_name, 1000, true)
        generate_report(top_queries, generate_report_filename(affiliate_name, day, '%Y%m'))
      end if args.generate_affiliates
    end

    desc "Generate Top Queries reports for the date specified"
    task :generate_daily_top_queries, :day, :generate_usasearch, :generate_affiliates, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number), :generate_usasearch => "true", :generate_affiliates => "true")
      day = Date.parse(args.day)
      establish_aws_connection
      %w{en es}.each do |locale|
        top_queries = Query.top_queries(day.beginning_of_day, day.end_of_day, locale, 'usasearch.gov', 1000, true)
        generate_report(top_queries, generate_report_filename(locale, day, '%Y%m%d'))
      end if args.generate_usasearch
      production_affiliate_names.each do |affiliate_name|
        top_queries = Query.top_queries(day.beginning_of_day, day.end_of_day, I18n.default_locale.to_s, affiliate_name, 1000, true)
        generate_report(top_queries, generate_report_filename(affiliate_name, day, '%Y%m%d'))
      end if args.generate_affiliates
    end

  end
end