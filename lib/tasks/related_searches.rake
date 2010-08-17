namespace :usasearch do
  namespace :related_searches do
    
    desc "Load JSON of related searches into the related_searches table"
    task :load_json, :filename, :needs => :environment do |t, args|
      if args.filename.blank?
        RAILS_DEFAULT_LOGGER.error "Usage: rake usasearch:related_searches:load_json[/path/to/json/file] RAILS_ENV=your_rails_environment"
      else
        RelatedQuery.load_json(args.filename)
      end
    end
    
    desc "Load CSV of affiliate related searches"
    task :load_affiliate_csv, :filename, :needs => :environment do |t, args|
      if args.filename.blank?
        RAILS_DEFAULT_LOGGER.error "Usage: rake usasearch:related_searches:load_affiliate_csv[/path/to/csv/file] RAILS_ENV=your_rails_env"
      else
        ProcessedQuery.load_csv(args.filename)
      end
    end
  end
    
    
    namespace :extract do   
      extract_query_sql = "select replace(query,'\\t',' '),SHA1(ipaddr),timestamp,affiliate,locale,agent,is_bot into outfile '_EXPORT_FILE_' fields terminated by '\\t' from queries "
      extract_click_sql = "select replace(query,'\\t',' '),SHA1(click_ip),queried_at,clicked_at,url,serp_position,affiliate,results_source,user_agent into outfile '_EXPORT_FILE_' fields terminated by '\\t' from clicks "
      where_clause = "where query not in ( 'enter keywords', 'cheesewiz' ,'clusty' ,' ', '1', 'test') and click_ip not in ('192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169') and query REGEXP'[[:alpha:]]+' and query NOT REGEXP'^[A-Za-z]{2}[0-9]+US$' and query NOT REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)'"

      # where query REGEXP'[[:alpha:]]+'  at least one alpha character.  strips: zip codes, phone numbers, FedEx tracking, USPS domestic tracking, 
      # credit card numbers
      # ^[A-Za-z]{2}[0-9]+US$   USPS intervational
      # REGEXP'@[[a-zA-Z0-9]+\\.(com|org|edu|net)'   Most non-government e-mails
      desc "extract click table to a tab delimited file.  Data extracted has IP addresses hashed using SHA1.  Queries have tabs replaced by spaces.  Queries with PII are not extracted."
      task :clicks => :environment do
        day = ENV["DAY"] || Date.yesterday.to_s(:number)
        yyyymmdd = day.to_i
        year = day.slice(0..3)
        month = day.slice(4..5)
        outfile = ENV["EXPORT_FILE"] || "/tmp/clicks-#{day}"
        limit = ENV["LIMIT"] || nil
        mod_sql = extract_click_sql.gsub("_EXPORT_FILE_",outfile)
        sql = "#{mod_sql} #{where_clause} AND date(clicked_at) = #{yyyymmdd}"
        if limit != nil
          sql << " LIMIT #{limit} "
        end
        ActiveRecord::Base.connection.execute(sql)
        #printf("%s\n",sql)

        # copy export file to S3 using s3cmd script
        %x{/usr/local/bin/s3cmd put #{outfile} s3://***REMOVED***/click_logs/#{year}/#{month}/clicks-#{yyyymmdd}}
        File.delete(outfile)
      end

      desc "extract query table to a tab delimited file.  Data extracted has IP addresses hashed using SHA1.  Queries have tabs replaced by spaces.  Queries with PII are not extracted."
      task :query => :environment do
       day = ENV["DAY"] || Date.yesterday.to_s(:number)
       yyyymmdd = day.to_i
       year = day.slice(0..3)
       month = day.slice(4..5)
       outfile = ENV["EXPORT_FILE"] || "/tmp/queries-#{day}"
       limit = ENV["LIMIT"] || nil
       mod_sql = extract_query_sql.gsub("_EXPORT_FILE_",outfile)
       sql = "#{mod_sql} #{where_clause} AND date(time      File.delete(outfile)
  stamp) = #{yyyymmdd}"
       if limit != nil
         sql << " LIMIT #{limit} "
       end
       ActiveRecord::Base.connection.execute(sql)
       #printf("%s\n",sql)

       # copy export file to S3 using s3cmd script
       %x{/usr/local/bin/s3cmd put #{outfile} s3://***REMOVED***/query_logs/#{year}/#{month}/queries-#{yyyymmdd}}
       File.delete(outfile)
      end
    end
  end
end