namespace :usasearch do
  namespace :query_log do

    desc "Process a directory of Vivisimo query log files (NCSA format 1)"
    task :process, :log_dir_name, :destination_log_dir_root, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:query_log:process log_dir_name destination_log_dir_root") and return if (args.log_dir_name.nil? || args.destination_log_dir_root.nil?)
      Dir.glob("#{args.log_dir_name}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.log") do |file|
        LogFile.process(file)
        destination_log_dir_name = File.basename(file)[0, 7]
        destination_dir = [args.destination_log_dir_root, destination_log_dir_name].join("/")
        FileUtils.mkdir(destination_dir) unless File.directory?(destination_dir)
        FileUtils.cp(file, destination_dir)
      end
    end

    desc "Import a directory of search query log files (NCSA combined)"
    task :import, :log_dir_name, :needs => :environment do |t, args|
      RAILS_DEFAULT_LOGGER.error("usage: rake usasearch:query_log:import log_dir_name") and return if args.log_dir_name.nil?
      Dir.glob("#{args.log_dir_name}/[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]_web*.log") { |file| LogFile.process(file) }
    end

    desc "Transform and filter a search query log file into a format that can be imported into Hive's queries table"
    task :transform_to_hive_queries_format, :file_name, :needs => :environment do |t, args|
      if args.file_name.nil?
        RAILS_DEFAULT_LOGGER.error "usage: rake usasearch:query_log:transform_to_hive_queries_format[file_name]"
      else
        LogFile.transform_to_hive_queries_format(args.file_name)
      end
    end

    namespace :extract do
      extract_query_sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(ipaddr) as ipaddr, timestamp, affiliate, locale, agent, is_bot FROM queries"
      extract_click_sql = "SELECT REPLACE(query, '\\t', ' ') as query, SHA1(click_ip) as click_ip, queried_at, clicked_at, url, serp_position, affiliate, results_source, user_agent FROM clicks"
      base_where_clause = "WHERE query not in ('enter keywords', 'cheesewiz', 'cheeseman', 'clusty', ' ', '1', 'test') AND query REGEXP'[[:alpha:]]+' AND query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' AND query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)'"
      ip_addresses = "('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169')"
      query_where_clause = "AND ipaddr NOT IN #{ip_addresses}"
      click_where_clause = "AND click_ip NOT IN #{ip_addresses}"

      # where query REGEXP'[[:alpha:]]+'  at least one alpha character.  strips: zip codes, phone numbers, FedEx tracking, USPS domestic tracking,
      # credit card numbers
      # ^[A-Za-z]{2}[0-9]+US$ - USPS intervational
      # REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)' - Most non-government e-mails
      desc "extract click table to a tab delimited file.  Data extracted has IP addresses hashed using SHA1.  Clicks have tabs replaced by spaces.  Clicks with PII are not extracted."
      task :clicks => :environment do
        day = ENV["DAY"] || Date.yesterday.to_s(:number)
        yyyymmdd = day.to_i
        year = day.slice(0..3)
        month = day.slice(4..5)
        outfile = ENV["EXPORT_FILE"] || "/tmp/clicks-#{day}"
        limit = ENV["LIMIT"] || nil
        sql = "#{extract_click_sql} #{base_where_clause} #{click_where_clause} AND date(clicked_at) = #{yyyymmdd}"
        if limit != nil
          sql << " LIMIT #{limit}"
        end

        options = {}
        options.merge!(:limit => limit.to_i) if limit.present?
        clicks = Click.find_by_sql(sql)
        FasterCSV.open(outfile, "w", :col_sep => "\t") do |csv|
          clicks.each do |click|
            csv << [click.query, click.click_ip, click.queried_at.strftime('%Y-%m-%d %H:%M:%S'), click.clicked_at.strftime('%Y-%m-%d %H:%M:%S'), click.url, click.serp_position, click.affiliate, click.results_source, click.user_agent]
          end
        end

        # copy export file to S3
        filename = "click_logs/#{year}/#{month}/clicks-#{yyyymmdd}"
        AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
        AWS::S3::S3Object.store(filename, Kernel.open(outfile), AWS_BUCKET_NAME)
        File.delete(outfile)
      end

      desc "extract query table to a tab delimited file.  Data extracted has IP addresses hashed using SHA1.  Queries have tabs replaced by spaces.  Queries with PII are not extracted."
      task :queries => :environment do
        day = ENV["DAY"] || Date.yesterday.to_s(:number)
        yyyymmdd = day.to_i
        year = day.slice(0..3)
        month = day.slice(4..5)
        outfile = ENV["EXPORT_FILE"] || "/tmp/queries-#{day}"
        limit = ENV["LIMIT"] || nil
        sql = "#{extract_query_sql} #{base_where_clause} #{query_where_clause} AND date(timestamp) = #{yyyymmdd}"
        if limit != nil
          sql << " LIMIT #{limit}"
        end

        queries = Query.find_by_sql(sql)
        FasterCSV.open(outfile, "w", :col_sep => "\t") do |csv|
          queries.each do |query|
            csv << [query.query, query.ipaddr, query.timestamp.strftime('%Y-%m-%d %H:%M:%S'), query.affiliate, query.locale, query.agent, query.is_bot ? "1" : "0"]
          end
        end

        # copy export file to S3
        filename = "query_logs/#{year}/#{month}/queries-#{yyyymmdd}"
        AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
        AWS::S3::S3Object.store(filename, Kernel.open(outfile), AWS_BUCKET_NAME)
        File.delete(outfile)
      end
    end
  end
end