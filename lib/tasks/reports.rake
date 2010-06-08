namespace :usasearch do
  namespace :reports do
   
   # this task is run once each night, what it does is calculate the top queries for the current month, format into a CSV file, and upload
   # that CSV file to Amazon S3 in a well known location. It should use the Queries table to calculate the top queries for the month because
   # the DailyQueryStats table does not have enough information.
   # We'll see, actually.  It does have enough information for English queries, but not for Spanish
   # English sould be 20K, Spanish 4K
    desc "Generate Top Queries reports for the month of the date specified"
    task :generate_monthly_top_queries, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, 
                                          :secret_access_key => AWS_SECRET_ACCESS_KEY)
      AWS::S3::Bucket.find('usasearch-reports') rescue AWS::S3::Bucket.create(REPORTS_AWS_BUCKET_NAME)
      locales = %w{en es}
      locales.each do |locale|
        top_queries = Query.top_queries(day.beginning_of_month.beginning_of_day, day.end_of_month.end_of_day, locale, 'usasearch.gov', locale == 'en' ? 20000: 4000, true)
        csv_string = FasterCSV.generate do |csv|
          csv << ["Query", "Count"]
          top_queries.each do |top_query|
            csv << [top_query.query, top_query.total]
          end
        end
        filename = "#{locale}_top_queries_#{day.strftime('%Y%m')}.csv"
        AWS::S3::S3Object.store(filename, csv_string, REPORTS_AWS_BUCKET_NAME)
      end
    end
    
    desc "Generate Top Queries reports for the date specified"
    task :generate_daily_top_queries, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      day = Date.parse(args.day)
      AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, 
                                          :secret_access_key => AWS_SECRET_ACCESS_KEY)
      AWS::S3::Bucket.find('usasearch-reports') rescue AWS::S3::Bucket.create(REPORTS_AWS_BUCKET_NAME)
      locales = %w{en es}
      locales.each do |locale|
        top_queries = Query.top_queries(day.beginning_of_day, day.end_of_day, locale, 'usasearch.gov', 1000, true)
        csv_string = FasterCSV.generate do |csv|
          csv << ["Query", "Count"]
          top_queries.each do |top_query|
            csv << [top_query.query, top_query.total]
          end
         end
        filename = "#{locale}_top_queries_#{day.strftime('%Y%m%d')}.csv"
        AWS::S3::S3Object.store(filename, csv_string, REPORTS_AWS_BUCKET_NAME)
      end
    end
  end
end