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

  config.ignore_request { |request| URI(request.uri).port.between?(9200, 9399) } # Elasticsearch and OpenSearch
  config.ignore_request { |request| URI(request.uri).port == 9998 } # Tika

  # Filter env variables used by VCR
  config.filter_sensitive_data('<ANALYTICS_ELASTICSEARCH>') { { reader: { hosts: [ENV.fetch('ES_HOSTS', nil)], user: ENV.fetch('ES_USER', nil), password: ENV.fetch('ES_PASSWORD', nil) }, writers: [{ hosts: [ENV.fetch('ES_HOSTS', nil)], user: ENV.fetch('ES_USER', nil), password: ENV.fetch('ES_PASSWORD', nil) }] } }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_ACCESS_KEY_ID>') { ENV.fetch('AWS_ACCESS_KEY_ID', nil) }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_SECRET_ACCESS_KEY>') { ENV.fetch('AWS_SECRET_ACCESS_KEY', nil) }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_BUCKET>') { ENV.fetch('AWS_BUCKET', nil) }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_S3_HOST_ALIAS>') { ENV.fetch('AWS_S3_HOST_ALIAS', nil) }
  config.filter_sensitive_data('<AWS_IMAGE_BUCKET_S3_REGION>') { ENV.fetch('AWS_REGION', nil) }
  config.filter_sensitive_data('<BING_V7_WEB_SUBSCRIPTION_ID>') { ENV.fetch('BING_WEB_SUBSCRIPTION_ID', nil) }
  config.filter_sensitive_data('<BING_V7_IMAGE_SUBSCRIPTION_ID>') { ENV.fetch('BING_IMAGE_SUBSCRIPTION', nil) }
  config.filter_sensitive_data('<CUSTOM_INDICES_ELASTICSEARCH>') { { reader: { hosts: [ENV.fetch('ES_HOSTS', nil)], user: ENV.fetch('ES_USER', nil), password: ENV.fetch('ES_PASSWORD', nil) }, writers: [{ hosts: [ENV.fetch('ES_HOSTS', nil)], user: ENV.fetch('ES_USER', nil), password: ENV.fetch('ES_PASSWORD', nil) }] } }
  config.filter_sensitive_data('<DATADOG_API_ENABLED>') { ENV.fetch('DATADOG_ENABLED', nil) }
  config.filter_sensitive_data('<DATADOG_API_KEY>') { ENV.fetch('DATADOG_API_KEY', nil) }
  config.filter_sensitive_data('<DATADOG_APPLICATION_KEY>') { ENV.fetch('DATADOG_APPLICATION_KEY', nil) }
  config.filter_sensitive_data('<EMAIL_ACTION_MAILER>') { { perform_deliveries: false, raise_delivery_errors: false } }
  config.filter_sensitive_data('<FLICKR_API_KEY>') { ENV.fetch('FLICKR_API_KEY', nil) }
  config.filter_sensitive_data('<FLICKR_SHARED_SECRET>') { ENV.fetch('FLICKR_SHARED_SECRET', nil) }
  config.filter_sensitive_data('<JOBS_SECRETS_USER_AGENT>') { ENV.fetch('USAJOBS_USER_AGENT', nil) }
  config.filter_sensitive_data('<JOBS_SECRETS_AUTHORIZATION_KEY>') { ENV.fetch('USAJOBS_AUTHORIZATION_KEY', nil) }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_CLIENT_ID>') { ENV.fetch('LOGIN_CLIENT_ID', nil) }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_IDP_BASE_URL>') { ENV.fetch('LOGIN_IDP_BASE_URL', nil) }
  config.filter_sensitive_data('<LOGIN_DOT_GOV_HOST>') { ENV.fetch('LOGIN_HOST', nil) }
  config.filter_sensitive_data('<NEWRELIC_SECRETS_LICENSE_KEY>') { ENV.fetch('NEWRELIC_LICENSE_KEY', nil) }
  config.filter_sensitive_data('<YOUTUBE_KEY>') { ENV.fetch('YOUTUBE_KEY', nil) }

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
