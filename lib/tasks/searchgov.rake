namespace :searchgov do
  desc 'Crawl a given domain, & optionally create searchgov_urls'
  # Usage: rake searchgov:crawl[www.foo.gov, srsly, skip, 0]

  # This task is not currently used in production and will likely be replaced by a more
  # robust crawler.
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
