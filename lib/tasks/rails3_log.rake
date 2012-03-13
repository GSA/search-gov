namespace :usasearch do
  namespace :rails3_log do
    desc "Transform and filter a multi-line Rails3 log file into a single line format that can be used in a Hive table"
    task :transform_to_hive_elapsed_times_format, :file_name, :needs => :environment do |t, args|
      if args.file_name.nil?
        Rails.logger.error "usage: rake usasearch:query_log:transform_to_hive_elapsed_times_format[file_name]"
      else
        File.open(args.file_name) do |file|
          file.each_line.map(&:strip).reject(&:empty?).slice_before(/Started (GET|POST|PUT|DELETE)/).each do |request_log_entry_array|
            request_url, total_time, view_time, db_time = request_log_entry_array.join(' ').
              scan(/^[^"]*"([^"]*)" .* Completed 200 OK in (\d*)ms [^\d]*(\d*)\.\d[^\d]*(\d*)\.\d/).first
            if (request_url)
              hash = ActiveSupport::OrderedHash.new
              %w{total_time db_time view_time request_url}.collect { |key| hash[key] = eval key }
              puts hash.to_json
            end
          end
        end
      end
    end
  end
end
