class SearchgovCrawler
  attr_reader :domain, :doc_links, :medusa_opts, :robotex, :srsly, :url_file

  def initialize(domain:, skip_query_strings: true, delay: nil, srsly: false)
    user_agent = DEFAULT_USER_AGENT
    @domain = domain
    @robotex = Robotex.new(user_agent)
    @srsly = srsly
    @medusa_opts = {
      discard_page_bodies: true,
      delay: (delay || robotex.delay(base_url)).to_i,
      obey_robots_txt: true,
      skip_query_strings: skip_query_strings,
      read_timeout: 30,
      threads: 8,
      verbose: true,
      user_agent: user_agent,
    }
    @doc_links = {}
    @url_file = initialize_url_file unless srsly
  end

  def crawl
    begin
      Medusa.crawl(base_url, @medusa_opts) do |medusa|
        medusa.skip_links_like(skip_extensions_regex)
        medusa.skip_links_like(repeating_segments_regex)

        medusa.on_every_page do |page|
          begin
            process_page(page)
          rescue => e
            Rails.logger.error("[SearchgovCrawler] Error crawling #{page.url}: #{e}".red)
          end
        end
      end

      create_application_document_urls
    ensure
      url_file&.close
    end
  end

  private

  def process_page(page)
    if page.visited.nil? && indexable?(page)
      url = current_url(page).to_s
      create_or_log_url(url, page.depth)
      extract_application_doc_links(page.links.map(&:to_s), page.depth + 1)
    end
  end

  def base_url
    @base_url ||= get_base_url
  end

  def get_base_url
    response = HTTP.follow.get("http://#{domain}")
    url = response.uri.to_s
    HtmlDocument.new(url: url, document: response.to_s).redirect_url || url
  end

  def indexable?(page)
    ([302,200].include? page.code) &&
      supported_content_type(page.headers['content-type']) &&
      current_url(page).host == domain
  end

  def application_extensions
    %w{doc docx pdf xls xlsx ppt pptx} #support powerpoint
  end

  def skip_extensions_regex
    /\.(#{(Fetchable::BLACKLISTED_EXTENSIONS + application_extensions ).join('|')})$/i
  end

  # avoid infinite loops caused by malformed urls
  def repeating_segments_regex
    /(\/[[:alpha:]]+)(?=\/)(.*\1(?=\/)){2,}/
  end

  def supported_content_type(type)
    SearchgovUrl::SUPPORTED_CONTENT_TYPES.any? do |ok_type|
      %r{#{ok_type}} === type
    end
  end

  def create_application_document_urls
    @doc_links.each { |url, depth| create_or_log_url(url, depth) }
  end

  def extract_application_doc_links(links, depth)
    application_doc_links = links.select do |link|
      robotex.allowed?(link) &&
        /\.(#{application_extensions.join("|")})$/i === link &&
        /\?/ !~ link
    end
    application_doc_links.each{ |link| doc_links.reverse_merge!( link => depth )  }
  end

  def create_or_log_url(url, depth)
    if srsly
      SearchgovUrl.create(url: url)
    else
      url_file << "#{url},#{depth}\n"
    end
  end

  def initialize_url_file
    path = "/tmp/searchgov_crawl_#{domain}_urls_#{Time.now.iso8601(2)}_#{Process.pid}"
    file = open(path, 'w')
    file << "url,depth\n"
    file
  end

  def current_url(page)
    page.redirect_to || page.url
  end
end
