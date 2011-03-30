namespace :usasearch do
  namespace :query_log do
    desc "Transform and filter a search query log file into a format that can be imported into Hive's queries table"
    task :transform_to_hive_queries_format, :file_name, :needs => :environment do |t, args|
      if args.file_name.nil?
        Rails.logger.error "usage: rake usasearch:query_log:transform_to_hive_queries_format[file_name]"
      else
        LogFile.transform_to_hive_queries_format(args.file_name)
      end
    end
  end
end