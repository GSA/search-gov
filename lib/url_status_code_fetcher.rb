require 'net/http'
require 'timeout'
require 'uri'

module UrlStatusCodeFetcher
  def self.fetch(urls, is_throttled = false, &block)
    return {} if urls.blank?
    urls = [urls] if urls.is_a?(String)

    options = load_options(is_throttled)
    per_request_timeout = options.dig(:easy_options, :timeout) || 15
    fetch_timeout = urls.count * per_request_timeout

    responses = {}
    mutex = Mutex.new

    fetch_with_timeout(fetch_timeout) do
      threads = urls.map do |url|
        Thread.new(url) do |inner_url|
          begin
            uri = URI.parse(inner_url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = (uri.scheme == 'https')
            http.read_timeout = per_request_timeout
            http.open_timeout = per_request_timeout

            response = http.request_head(uri.path.presence || '/')
            status = "#{response.code} #{response.message}"

            if block_given?
              yield inner_url, status
            else
              mutex.synchronize { responses[inner_url] = status }
            end
          rescue => e
            Rails.logger.warn("UrlStatusCodeFetcher failed for #{inner_url}: #{e.message}")
          end
        end
      end
      threads.each(&:join)
    end

    responses unless block_given?
  end

  def self.load_options(is_throttled)
    config = load_config
    is_throttled ? config[:throttled] : config[:default]
  end

  def self.load_config
    YAML.load_file(Rails.root.join('config/url_status_code_fetcher.yml'), aliases: true)
  end

  def self.fetch_with_timeout(timeout_in_seconds, &block)
    Timeout.timeout(timeout_in_seconds, &block)
  rescue Timeout::Error
    Rails.logger.warn 'UrlStatusCodeFetcher execution expired'
  end
end