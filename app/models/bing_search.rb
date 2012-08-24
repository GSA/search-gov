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

  protected

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
end