# frozen_string_literal: true

PAPERCLIP_MATCHERS = {
  affiliate: {
    regex: %r{^/(?<env>[^/]+)/site/(?<id>\d*)/(?<image_type>[^/]+)/(?<updated_at>[^/]+)/(?<style>[^/]+)/(?<filename>[^/]+)},
    fields_to_match: %w[env image_type style filename]
  },
  featured_collection: {
    regex: %r{^/(?<env>[^/]+)/featured_collection/(?<id>\d*)/image/(?<updated_at>[^/]+)/(?<style>[^/]+)/(?<filename>[^/]+)},
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
    clean_outdated_http_interactions: true
  }

  config.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' || !http_message.body.valid_encoding?
  end

  config.ignore_hosts 'example.com', 'codeclimate.com', '127.0.0.1', 'googlechromelabs.github.io'
  config.ignore_request do |request|
    /codeclimate.com/ ===  URI(request.uri).host
  end

  config.ignore_request { |request| URI(request.uri).port.between?(9200, 9299) } # Elasticsearch
  config.ignore_request { |request| URI(request.uri).port == 9998 } # Tika

  # Filter env variables used by VCR
  config.filter_sensitive_data('<ANALYTICS_ELASTICSEARCH>') { { reader: { hosts: [ENV['ES_HOSTS']], user: ENV['ES_USER'], password: ENV['ES_PASSWORD'] }, writers: [{ hosts: [ENV['ES_HOSTS']], user: ENV['ES_USER'], password: ENV['ES_PASSWORD'] }] } }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_ACCESS_KEY_ID>') { ENV['AWS_ACCESS_KEY_ID'] }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_SECRET_ACCESS_KEY>') { ENV['AWS_SECRET_ACCESS_KEY'] }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_BUCKET>') { ENV['AWS_BUCKET'] }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_S3_HOST_ALIAS>') { ENV['AWS_S3_HOST_ALIAS'] }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_S3_REGION>') { ENV['AWS_REGION'] }
  config.filter_sensitive_data('<BING_V7_WEB_SUBSCRIPTION_ID>') { ENV['BING_WEB_SUBSCRIPTION_ID'] }
  config.filter_sensitive_data('<BING_V7_IMAGE_SUBSCRIPTION_ID>') { ENV['BING_IMAGE_SUBSCRIPTION'] }
  config.filter_sensitive_data('<CUSTOM_INDICES_ELASTICSEARCH>') { { reader: { hosts: [ENV['ES_HOSTS']], user: ENV['ES_USER'], password: ENV['ES_PASSWORD'] }, writers: [{ hosts: [ENV['ES_HOSTS']], user: ENV['ES_USER'], password: ENV['ES_PASSWORD'] }] } }
  config.filter_sensitive_data('<DATADOG_API_ENABLED>') { ENV['DATADOG_ENABLED'] }
  config.filter_sensitive_data('<DATADOG_API_KEY>') { ENV['DATADOG_API_KEY'] }
  config.filter_sensitive_data('<DATADOG_APPLICATION_KEY>') { ENV['DATADOG_APPLICATION_KEY'] }
  config.filter_sensitive_data('<EMAIL_ACTION_MAILER>') { { perform_deliveries: false, raise_delivery_errors: false } }
  config.filter_sensitive_data('<FLICKR_API_KEY>') { ENV['FLICKR_API_KEY'] }
  config.filter_sensitive_data('<FLICKR_SHARED_SECRET>') { ENV['FLICKR_SHARED_SECRET'] }
  config.filter_sensitive_data('<JOBS_SECRETS_USER_AGENT>') { ENV['USAJOBS_USER_AGENT'] }
  config.filter_sensitive_data('<JOBS_SECRETS_AUTHORIZATION_KEY>') { ENV['USAJOBS_AUTHORIZATION_KEY'] }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_CLIENT_ID>') { ENV['LOGIN_CLIENT_ID'] }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_IDP_BASE_URL>') { ENV['LOGIN_IDP_BASE_URL'] }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_HOST>') { ENV['LOGIN_HOST'] }
  config.filter_sensitive_data('<NEWRELIC_SECRETS_LICENSE_KEY>') { ENV['NEWRELIC_LICENSE_KEY'] }
  config.filter_sensitive_data('<YOUTUBE_KEY>') { ENV['YOUTUBE_KEY'] }

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  # Capybara: http://stackoverflow.com/a/6120205/1020168
  config.ignore_request do |request|
    URI(request.uri).request_uri == '/__identify__'
  end

  # For future debugging reference:
  # config.debug_logger = STDOUT
end
