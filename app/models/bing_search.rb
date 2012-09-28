class BingSearch
  class BingSearchError < RuntimeError;
  end

  JSON_SITE = "http://api.bing.net/json.aspx"
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  VALID_FILTER_VALUES = %w{off moderate strict}
  DEFAULT_FILTER_SETTING = 'moderate'
  URI_REGEX = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
  USER_AGENT = "USASearch"

  def initialize(user_agent = USER_AGENT)
    @user_agent = user_agent
  end

  def query(query, sources, offset = 0, per_page = 10, enable_highlighting = true, filter_setting = DEFAULT_FILTER_SETTING)
    begin
      uri = URI.parse(bing_api_url(query, sources, offset, per_page, enable_highlighting, filter_setting))
      Rails.logger.debug("URI to Bing: #{uri}")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new(uri.request_uri)
      req["User-Agent"] = @user_agent
      response = http.request(req)
      response.body
    rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH, Timeout::Error, EOFError, Errno::ETIMEDOUT => error
      raise BingSearchError.new(error.to_s)
    end
  end

  def parse_bing_response(response_body)
    begin
      json = JSON.parse(response_body)
      json.nil? || json['SearchResponse'].blank? ? nil : ResponseData.new(json['SearchResponse'])
    rescue JSON::ParserError => error
      raise BingSearchError.new(error.to_s)
    end
  end

  def self.search_for_url_in_bing(url)
    candidate_urls = []
    parsed_url = URI.parse(url)
    parsed_url.fragment = nil
    candidate_urls << parsed_url.to_s

    parsed_url.query = nil
    candidate_urls << parsed_url.to_s

    candidate_urls.uniq.each do |candidate_url|
      result = url_in_bing(candidate_url)
      return result if result
    end
    nil
  rescue Exception => e
    Rails.logger.warn("Trouble determining if URL is in bing: #{e}")
    nil
  end

  protected

  def self.url_in_bing(url)
    normalized_url = normalized_url(url)

    bing_url =  BingUrl.find_by_normalized_url(normalized_url)
    return bing_url.normalized_url if bing_url

    bing_search = BingSearch.new
    response = bing_search.query(url, 'Web', 0, 10, false, 'off')
    bing_results = bing_search.parse_bing_response(response)
    if bing_results and bing_results.web and bing_results.web.total > 0 and bing_results.web.results.present?
      result_urls = bing_results.web.results.collect { |r| r['Url'] }
      result_urls.each do |result_url|
        url_in_bing = normalized_url(result_url)
        if normalized_url.to_s.downcase == url_in_bing.downcase
          return url_in_bing
        end
      end
    end
    nil
  rescue Exception
  end

  def bing_api_url(query_string, query_sources, offset, count, enable_highlighting, filter_setting)
    params = [
      "web.offset=#{offset}",
      "web.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{query_sources}",
      "Options=#{ enable_highlighting ? "EnableHighlighting" : ""}",
      "Adult=#{filter_setting}",
      "query=#{URI.escape(query_string, URI_REGEX)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  def self.normalized_url(url)
    parsed_url = URI.parse(url)
    parsed_url.path = parsed_url.path.empty? ? '/' : parsed_url.path
    parsed_url.fragment = nil
    parsed_url.to_s.gsub(%r[https?://(www\.)?]i, '')
  end
end