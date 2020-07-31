require 'yaml'

PAPERCLIP_MATCHERS = {
  affiliate: {
    regex: /^\/(?<env>[^\/]+)\/site\/(?<id>\d*)\/(?<image_type>[^\/]+)\/(?<updated_at>[^\/]+)\/(?<style>[^\/]+)\/(?<filename>[^\/]+)/,
    fields_to_match: %w[env image_type style filename]
  },
  featured_collection: {
    regex: /^\/(?<env>[^\/]+)\/featured_collection\/(?<id>\d*)\/image\/(?<updated_at>[^\/]+)\/(?<style>[^\/]+)\/(?<filename>[^\/]+)/,
    fields_to_match: %w[env style filename]
  }
}.freeze

VCR.configure do |config|
  config.hook_into :webmock

  config.register_request_matcher :uri_with_paperclip_normalization do |request_1, request_2|
    PAPERCLIP_MATCHERS.detect do |_url_type, rules|
      req1_parts = URI(request_1.uri).path.match(rules[:regex])
      req2_parts = URI(request_2.uri).path.match(rules[:regex])
      req1_parts && req2_parts &&
        rules[:fields_to_match].all? do |f|
          req1_parts[f] == req2_parts[f]
        end
    end || (request_1.uri == request_2.uri)
  end

  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri_with_paperclip_normalization],
    clean_outdated_http_interactions: true,
  }

  config.ignore_hosts 'example.com', 'codeclimate.com'
  config.ignore_request do |request|
    /codeclimate.com/ ===  URI(request.uri).host
  end

  config.ignore_request { |request| URI(request.uri).port.between?(9200,9299) } #Elasticsearch
  config.ignore_request { |request| URI(request.uri).port == 9515 } # Selenium Webdriver
  config.ignore_request { |request| URI(request.uri).port == 9517 } # Chrome Webdriver

  secrets = YAML.load(ERB.new(File.read(Rails.root.join('config', 'secrets.yml'))).result)
  secrets['secret_keys'].each do |service, keys|
    keys.each do |name, key|
      config.filter_sensitive_data("<#{service.upcase}_#{name.upcase}>") { key }
    end
  end

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  #Capybara: http://stackoverflow.com/a/6120205/1020168
  config.ignore_request do |request|
    URI(request.uri).request_uri == "/__identify__"
  end

  #For future debugging reference:
  #config.debug_logger = STDOUT
end
