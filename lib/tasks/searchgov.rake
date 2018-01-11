require 'medusa'
require 'csv'

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

  task :index_sitemap, [:sitemap_url] => [:environment] do |_t, args|
    
  end



  task :crawl, [:domain,:skip_query_strings,:depth] => [:environment] do |_t, args|
    @domain = args[:domain]
    @site = find_site(@domain) #HTTP.follow.get("http://#{@domain}").uri.to_s
    @srsly = false #args[:srsly]
    @depth = args[:depth]&.to_i
    @skip = args[:skip_query_strings] || true
    crawler = :medusa #args[:crawler].to_sym
    @file = CSV.open("crawls/#{@domain}_#{crawler}_depth_#{@depth}_#{Time.now.strftime("%m-%d-%y_%H_%M")}", 'w')

    puts "Preparing to to crawl #{@site} with #{crawler}. Output file: #{@file.path}"
    puts "Not creating searchgov urls because --srsly wasn't indicated".magenta unless @srsly
    time = Benchmark.realtime { self.send(crawler) }

    @file << ["Elapsed time: #{time}"]

    @file.close
    puts "Crawling complete. Elapsed time: #{time}. Output file: #{@file.path}"
  end

  task :promote, [:url_file, :boolean] => [:environment] do |_t, args|
    url_file = args.url_file
    @bool = args.boolean
    line_count = `wc -l < #{url_file}`.to_i
    drawer = I14yDrawer.find_by_handle('searchgov')
    CSV.foreach(url_file) do |row|
      url = row.first
      begin
        puts "[#{$INPUT_LINE_NUMBER}/#{line_count}] Preparing to promote #{url}"
        url = HTTP.follow.get(url).uri.to_s #FIXME
        puts "url redirected to #{url}" if url != row.first
        su = SearchgovUrl.find_by_url(url) || SearchgovUrl.create(url: url)#find or create
        su.fetch
        response = HTTP.basic_auth(user: 'searchgov',pass: drawer.token).
          put("http://localhost:8081/api/v1/documents/#{su.document_id}", json: {promote: @bool})
        puts "promoted #{su.url}".green if response.status == 200
      rescue => error
        puts "Failed to index #{url}:\n#{error}".red
      end
    end

  end
end

=begin
@robotex = Robotex.new
@token = I14yDrawer.find_by_handle('searchgov').token
SearchgovUrl.find_each do | su|
  url = su.url
  doc_id = su.document_id
  if !@robotex.allowed?(url)
    puts HTTP.basic_auth(user: 'searchgov',pass: @token).delete("http://localhost:8081/api/v1/documents/#{doc_id}").body.to_s
    su.update_attributes!(last_crawl_status: 'disallowed')
  end
end
=end


#HTTP.basic_auth(user: 'searchgov',pass: '9e734b355287f5047d0b1a74c264eb71').put('http://localhost:8081/api/v1/documents/ba386696fe27f3369cce0ae8e46e1dd3dd5a16f568c0a59e658ab8f7d91d6b6f', json: {promote: true})

# Config settings to be used for each:
# - obey robots.txt
# - only list successfully retrieved URLs (status code 200)
# - only internal urls
# - only pages with our supported mimetypes (SearchgovUrl::SUPPORTED_CONTENT_TYPES)
# - omit query strings
#
def spidr
  # NOTE: to run this crawler, you'll need to comment out the cobweb gem and bundle install
  # to avoid class name conflicts

  # crawling options:
  # https://github.com/postmodern/spidr/blob/a197f2f030a4cf9a00244a3677014dfc633843d4/lib/spidr/agent.rb#L102
  options = {
    robots: true,
    user_agent: 'usasearch',
    #delay:
  }

  Spidr.site(@site, options) do |spider|
    spider.every_ok_page do |page|
      if supported_content_type(page.content_type)
        puts page.url
        @file << [page.url]
      end
    end
  end
end

def spider
  Spider.start_at(@site) do |s|
    s.add_url_check { |url| url =~ %r{^"#{@site}"}  }
    s.on :success do |a_url, resp, prior_url|
      puts "#{a_url}: #{resp.code}"
    end
  end
end

def cobweb
  # crawling options:
  # https://github.com/stewartmckee/cobweb#newoptions
  options = {
    crawl_id: Time.now.to_i,
    obey_robots: true,
    thread_count: 8,
    timeout: 30,
    valid_mime_types: SearchgovUrl::SUPPORTED_CONTENT_TYPES #this doesn't seem to work...
  }

  crawler = CobwebCrawler.new(options)

  stats = crawler.crawl(@site) do |page|
    # data/methods per page: https://github.com/stewartmckee/cobweb#data-returned-for-each-page--the-data-available-in-the-returned-hash-are
    if page[:status_code] == 200 && supported_content_type( page[:headers][:'content-type'].first )
      puts page[:url]
      @file << [page[:url]]
    end
  end
end

def medusa
  # crawling options:
  # https://github.com/brutuscat/medusa/blob/master/lib/medusa/core.rb#L28
  options = {
    discard_page_bodies: true,
    #delay: 1,
    obey_robots_txt: true,
    skip_query_strings: @skip, #FIXME
    read_timeout: 30,
    threads: 8, #(default is 4),
    verbose: true, #,
    depth_limit: @depth,
  }

  skip_extensions = %w{doc docx pdf xls xlsx ppt}
  application_extensions = %w{doc docx pdf ppt}
  @doc_links = Set.new
  @robotex = Robotex.new
   ##
  #    uri = Addressable::URI.parse(url)
   # self.url = uri.try(:omit, :query).to_s

   Medusa.crawl(@site, options) do |medusa|
     medusa.skip_links_like(/\.(#{(Fetchable::BLACKLISTED_EXTENSIONS + skip_extensions ).join('|')})$/i)

     medusa.on_every_page do |page|
       #puts "Links: #{page.links}---------------"
      # puts "#{page.url}, #{page.code}, time: #{page.response_time}, depth: #{page.depth}, redirected: #{page.redirect_to}, referer: #{page.referer}, visited: #{page.visited.nil?}"
      # url = page.code == 301 ? page.redirect_to.to_s : page.url.to_s
       url = page.redirect_to.present? ? page.redirect_to.to_s : page.url.to_s
       if options[:skip_query_strings] == true
         uri = Addressable::URI.parse(url)
         url = uri.try(:omit, :query).to_s
       end
       #url = (page.redirect_to || page.url).to_s
      #data/methods per page: https://github.com/brutuscat/medusa/blob/master/lib/medusa/page.rb#L8
       if ([302,200].include? page.code) && page.visited.nil? && supported_content_type(page.headers['content-type'])
        #puts page.url
        #  puts page.links #to file?
        SearchgovUrl.create(url: url) if @srsly
        links = page.links.map(&:to_s)
        links = links.select do |link|
          begin
          /\.(#{application_extensions.join("|")})/i === link && @robotex.allowed?(link)
          rescue => e
            puts "#{e}, #{link}".red
          end
        end
        links.each{|link| @doc_links << [link,page.depth + 1 ] }
        links.each{|link| puts "#{link}".blue }

        @file << [url, page.depth] #, page.code, page.depth]
      end
    end
   end
    ##

  puts "DOC COUNT: #{@doc_links.count}" 

  @file << ["DOC LINKS BELOW"]
  @doc_links.each do |link|
    @file << link
    SearchgovUrl.create(url: link) if @srsly
  end

  index_new_links if @srsly
end

def index_new_links
  SearchgovUrl.where(last_crawl_status: nil).find_each do |su|
    puts "indexing #{su}".yellow
    su.fetch
  end
end

def supported_content_type(type)
  SearchgovUrl::SUPPORTED_CONTENT_TYPES.any? do |ok_type|
    %r{#{ok_type}} === type
  end
end

def find_site(domain)
  begin
    HTTP.follow.get("http://#{@domain}").uri.to_s
  rescue HTTP::ConnectionError
    puts "trying https..."
    HTTP.follow.get("https://#{@domain}").uri.to_s
  end
end
