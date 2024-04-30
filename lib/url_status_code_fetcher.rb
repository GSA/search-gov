require 'timeout'

module UrlStatusCodeFetcher
  def self.fetch(urls, is_throttled = false, &block)
    return {} if urls.blank?
    urls = [urls] if urls.is_a?(String)

    options = load_options is_throttled
    easy_options = { method: :head }.reverse_merge options[:easy_options]
    responses = {}
    fetch_timeout = urls.count * options[:easy_options][:timeout]

    fetch_with_timeout(fetch_timeout) do
      Curl::Multi.get urls, easy_options, options[:multi_options] do |easy|
        if block_given?
          yield easy.url, easy.status
        else
          responses[easy.url] = easy.status
        end
      end
    end
    responses unless block_given?
  end

  def self.load_options(is_throttled)
    config = load_config
    is_throttled ? config[:throttled] : config[:default]
  end

  def self.load_config
    YAML.load_file(Rails.root.join('config/url_status_code_fetcher.yml'), aliases: true)
  rescue ArgumentError
    YAML.load_file(Rails.root.join('config/url_status_code_fetcher.yml'))
  end

  def self.fetch_with_timeout(timeout_in_seconds, &block)
    Timeout::timeout timeout_in_seconds do
      yield
    end
  rescue Timeout::Error
    Rails.logger.warn 'UrlStatusCodeFetcher execution expired'
  end
end
