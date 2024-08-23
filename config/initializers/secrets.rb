# frozen_string_literal: true

analytics = {
  elasticsearch: {
    reader: {
      hosts: ENV['ES_HOSTS'].split(','),
      user: ENV.fetch('ES_USER', nil),
      password: ENV.fetch('ES_PASSWORD', nil)
    },
    writers: [
      {
        hosts: ENV['ES_HOSTS'].split(','),
        user: ENV.fetch('ES_USER', nil),
        password: ENV.fetch('ES_PASSWORD', nil)
      }
    ]
  }
}

aws_image_bucket = {
  access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
  bucket: ENV.fetch('AWS_BUCKET', nil),
  s3_host_alias: ENV.fetch('AWS_S3_HOST_ALIAS', nil),
  s3_region: ENV.fetch('AWS_REGION', nil)
}

bing_v7 = {
  web_subscription_id: ENV.fetch('BING_WEB_SUBSCRIPTION_ID', nil),
  image_subscription_id: ENV.fetch('BING_IMAGE_SUBSCRIPTION', nil)
}

custom_indices = {
  elasticsearch: {
    reader: {
      hosts: ENV['ES_HOSTS'].split(','),
      user: ENV.fetch('ES_USER', nil),
      password: ENV.fetch('ES_PASSWORD', nil)
    },
    writers: [
      {
        hosts: ENV['ES_HOSTS'].split(','),
        user: ENV.fetch('ES_USER', nil),
        password: ENV.fetch('ES_PASSWORD', nil)
      }
    ]
  }
}

datadog = {
  api_enabled: ENV.fetch('DATADOG_ENABLED', nil),
  api_key: ENV.fetch('DATADOG_API_KEY', nil),
  application_key: ENV.fetch('DATADOG_APPLICATION_KEY', nil)
}

email = {
  action_mailer: {
    perform_deliveries: false,
    raise_delivery_errors: false
  }
}

flickr = {
  api_key: ENV.fetch('FLICKR_API_KEY', nil),
  shared_secret: ENV.fetch('FLICKR_SHARED_SECRET', nil)
}

jobs_secrets = {
  user_agent: ENV.fetch('USAJOBS_USER_AGENT', nil),
  authorization_key: ENV.fetch('USAJOBS_AUTHORIZATION_KEY', nil)
}

login_dot_gov = {
  client_id: ENV.fetch('LOGIN_CLIENT_ID', nil),
  idp_base_url: ENV.fetch('LOGIN_IDP_BASE_URL', nil),
  host: ENV.fetch('LOGIN_HOST', nil)
}

newrelic_secrets = {
  license_key: ENV.fetch('NEWRELIC_LICENSE_KEY', nil)
}

youtube = {
  key: ENV.fetch('YOUTUBE_KEY', nil)
}

secret_keys = {
  analytics:,
  aws_image_bucket:,
  bing_v7:,
  custom_indices:,
  datadog:,
  email:,
  flickr:,
  jobs_secrets:,
  login_dot_gov:,
  newrelic_secrets:,
  youtube:
}

Rails.application.config.secret_keys = secret_keys
