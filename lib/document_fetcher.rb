module DocumentFetcher
  DEFAULT_MAX_REDIRECTS = 5

  # Caveat fetcher: These requests cannot be recorded by VCR:
  # https://cm-jira.usa.gov/browse/SRCH-645
  def self.fetch(url, connect_timeout: 2, read_timeout: 8)
    easy = Curl::Easy.new(url) do |c|
      c.connect_timeout = connect_timeout
      c.follow_location = true
      c.max_redirects = DEFAULT_MAX_REDIRECTS
      c.timeout = read_timeout
      c.useragent = DEFAULT_USER_AGENT
      c.on_success { return handle_success_or_redirect easy }
      c.on_redirect { return handle_success_or_redirect easy }
    end
    easy.perform
    { error: "Unable to fetch #{url}" }
  rescue => e
    Rails.logger.warn "#{self.name} fetch error url: #{url} error: #{e.message}"
    { error: e.message }
  end

  private

  def self.handle_success_or_redirect(easy)
    { body: easy.body,
      last_effective_url: easy.last_effective_url,
      status: easy.status }
  end
end
