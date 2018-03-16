namespace :searchgov do
  desc 'Bulk index urls into Search.gov'
  # Usage: rake searchgov:bulk_index[my_urls.csv,10]

  task :bulk_index, [:url_file, :sleep_seconds] => [:environment] do |_t, args|
    url_file = args.url_file
    line_count = `wc -l < #{url_file}`.to_i
    delay = (args.sleep_seconds.to_i || 10)
    CSV.foreach(url_file) do |row|
      url = row.first
      begin
        puts "[#{$INPUT_LINE_NUMBER}/#{line_count}] Preparing to index #{url}"
        searchgov_url = SearchgovUrl.create!(url: url)
        sleep(delay) #to avoid getting us blacklisted...
        searchgov_url.fetch
        status = searchgov_url.last_crawl_status
        (status == 'OK') ? (puts "Indexed #{searchgov_url.url}".green) : (puts "Failed to index #{url}:\n#{status}".red)
      rescue => error
        puts "Failed to index #{url}:\n#{error}".red
      end
    end
    puts "Fetching new urls"
    SearchgovUrl.fetch_new
  end

  desc 'Promote (or demote) a list of urls in the searchgov index'
  # Usage:
  # Promote: rake searchgov:promote[important_urls.csv]
  # Demote:  rake searchgov:promote[important_urls.csv,false]

  task :promote, [:url_file, :boolean] => [:environment] do |_t, args|
    url_file = args.url_file
    boolean = args.boolean || 'true'
    CSV.foreach(url_file) do |row|
      url = row.first
      begin
        searchgov_url = SearchgovUrl.find_or_create_by!(url: url)
        searchgov_url.fetch unless searchgov_url.last_crawl_status == 'OK'
        I14yDocument.promote(handle: 'searchgov',
                             document_id: searchgov_url.document_id,
                             bool: boolean )
        puts "Promoted #{url}".green
      rescue => error
        puts "Failed to promote #{url}:\n#{error}".red
      end
    end
  end

  desc 'Crawl a given domain, & optionally create searchgov_urls'
  # Usage: rake searchgov:crawl[www.foo.gov, srsly, skip, 0]

  task :crawl, [:domain, :srsly, :skip, :delay] => [:environment] do |_t, args|
    @domain = args[:domain]
    @srsly = (args[:srsly] == 'srsly')
    @skip = (args[:skip] == 'skip')
    @delay = (args[:delay].to_i || 10)

    puts "Not creating searchgov urls because --srsly wasn't indicated" unless @srsly
    puts "Skipping query strings? #{@skip}"

    crawler = SearchgovCrawler.new(domain: @domain, skip_query_strings: @skip, srsly: @srsly, delay: @delay)

    puts "Preparing to crawl #{@domain}."

    crawler.crawl

    puts "Crawling complete."
    puts "Output file: #{crawler.url_file.path}" unless @srsly
  end
end
