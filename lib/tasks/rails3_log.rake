namespace :usasearch do
  namespace :rails3_log do
    desc "Transform and filter a multi-line Rails3 log file into a single line format that can be used in a Hive table"
    task :transform_to_hive_elapsed_times_format, :file_name, :needs => :environment do |t, args|
      if args.file_name.nil?
        Rails.logger.error "usage: rake usasearch:rails3_log:transform_to_hive_elapsed_times_format[file_name]"
      else
        start_regexp = Regexp.new '^Started (?:GET|POST|PUT|DELETE)? "([^"]*)"'
        end_regexp = Regexp.new '^Completed 200 OK in (\d*)ms(?: [^\d]*(\d*)\.\d[^\d]*(\d*)\.\d[^\d]*(\d*)\.\d)?'
        request_hash = ActiveSupport::OrderedHash.new
        File.foreach(args.file_name) do |line|
          request_url = line.scan(start_regexp)[0][0] rescue nil
          if request_url
            request_hash.clear
            request_hash[:request_url] = request_url
          end

          total_time, view_time, db_time, solr_time = line.scan(end_regexp)[0] rescue nil
          next unless total_time and request_hash[:request_url]

          request_hash[:total_time] = total_time
          request_hash[:db_time] = db_time if db_time
          request_hash[:view_time] = view_time if view_time
          request_hash[:solr_time] = solr_time if solr_time
          puts request_hash.to_json
        end
      end
    end
  end
end
