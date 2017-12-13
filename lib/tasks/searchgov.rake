namespace :searchgov do
  desc 'Bulk index urls into Search.gov'
  # Usage: rake searchgov:bulk_index[my_urls.csv,10]

  task :bulk_index, [:url_file, :sleep_seconds] => [:environment] do |_t, args|
    url_file = args.url_file
    line_count = `wc -l < #{url_file}`.to_i
    CSV.foreach(url_file) do |row|
      url = row.first
      begin
        puts "[#{$INPUT_LINE_NUMBER}/#{line_count}] Preparing to index #{url}"
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

  task :promote, [:url_file, :boolean] => [:environment] do |_t, args|
    url_file = args.url_file
    boolean = args.boolean || 'true'
    CSV.foreach(url_file) do |row|
      url = row.first
      begin
        searchgov_url = SearchgovUrl.find_or_create_by_url!(url)
        searchgov_url.fetch unless searchgov_url.last_crawl_status == 'OK'
        I14yDocument.promote(handle: 'searchgov',
                             document_id: searchgov_url.document_id,
                             bool: boolean )
      rescue => error
        puts "Failed to promote #{url}:\n#{error}".red
      end
    end
  end
end
