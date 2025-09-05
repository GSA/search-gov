module DocumentFetcher
  DEFAULT_MAX_REDIRECTS = 5

  # Caveat fetcher: These requests cannot be recorded by VCR:
  # https://cm-jira.usa.gov/browse/SRCH-645
  def self.fetch(url, connect_timeout: 2, read_timeout: 8, limit: DEFAULT_MAX_REDIRECTS)
    raise ArgumentError, 'Too many redirects' if limit.zero?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = connect_timeout
    http.read_timeout = read_timeout
    request = Net::HTTP::Get.new(uri.request_uri)
    request['User-Agent'] = DEFAULT_USER_AGENT
    response = http.request(request)

    case response
    when Net::HTTPSuccess
      { status: response.code, body: response.body, last_effective_url: uri.to_s }
    when Net::HTTPRedirection
      fetch(response['location'], connect_timeout: connect_timeout, read_timeout: read_timeout, limit: limit - 1)
    else
      { error: "#{response.code} #{response.message}" }
    end
  rescue => e
    Rails.logger.error "#{self.name} fetch error url: #{url}", e
    { error: e.message }
  end

  private


end
