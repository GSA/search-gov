namespace :searchgov do
  desc 'Bulk index urls into Search.gov'
  # Usage: rake searchgov:bulk_index[my_urls.csv,10]

  task :bulk_index, [:url_file, :sleep_seconds] => [:environment] do |_t, args|
    CSV.foreach(args.url_file) do |row|
      url = row.first
      begin
        puts "Preparing to index #{url}"
        searchgov_url = SearchgovUrl.create!(url: url)
        sleep(args.sleep_seconds.to_i || 10) #to avoid getting us blacklisted...
        searchgov_url.fetch
        status = searchgov_url.last_crawl_status
        (status == 'OK') ? (puts "Indexed #{searchgov_url.url}".green) : (puts "Failed to index #{url}:\n#{status}".red)
      rescue => error
        puts "Failed to index #{url}:\n#{error}".red
      end
    end
  end
end
