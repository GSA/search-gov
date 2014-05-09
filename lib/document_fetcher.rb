module DocumentFetcher
  DEFAULT_FETCH_TIMEOUT = 10.freeze
  DEFAULT_MAX_REDIRECT = 5.freeze

  def self.fetch(url)
    Timeout::timeout DEFAULT_FETCH_TIMEOUT do
      easy = Curl::Easy.new(url) do |c|
        c.follow_location = true
        c.max_redirects = DEFAULT_MAX_REDIRECT
        c.timeout = DEFAULT_FETCH_TIMEOUT
        c.useragent = DEFAULT_USER_AGENT
        c.on_success { |easy| return handle_success_or_redirect easy }
        c.on_redirect { |easy| return handle_success_or_redirect easy }
      end
      easy.perform rescue nil
      {}
    end
  rescue Timeout::Error
    Rails.logger.warn "#{self.name} execution expired when fetching #{url}"
    {}
  end

  private

  def self.handle_success_or_redirect(easy)
    { body: easy.body,
      last_effective_url: easy.last_effective_url,
      status: easy.status }
  end
end
