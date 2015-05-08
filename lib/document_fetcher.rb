module DocumentFetcher
  DEFAULT_OPEN_TIMEOUT = 2
  DEFAULT_TIMEOUT = 8
  DEFAULT_MAX_REDIRECTS = 5

  def self.fetch(url)
    easy = Curl::Easy.new(url) do |c|
      c.connect_timeout = DEFAULT_OPEN_TIMEOUT
      c.follow_location = true
      c.max_redirects = DEFAULT_MAX_REDIRECTS
      c.timeout = DEFAULT_TIMEOUT
      c.useragent = DEFAULT_USER_AGENT
      c.on_success { |easy| return handle_success_or_redirect easy }
      c.on_redirect { |easy| return handle_success_or_redirect easy }
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
