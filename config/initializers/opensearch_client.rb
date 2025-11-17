# frozen_string_literal: true

require 'elasticsearch'

# NOTE: This is using the Elasticsearch::Client because the opensearch-ruby gem
# has a dependency on a newer version of faraday than is allowed by the
# omniauth_login_dot_gov gem.
#
# The elasticsearch-ruby gem is compatible with OpenSearch.
OPENSEARCH_CLIENT = Elasticsearch::Client.new(
  url: ENV.fetch('OPENSEARCH_SEARCH_HOST', 'http://localhost:9300'),
  user: ENV.fetch('OPENSEARCH_SEARCH_USER', 'admin'),
  password: ENV['OPENSEARCH_SEARCH_PASSWORD'],
  port: ENV.fetch('OPENSEARCH_SEARCH_PORT', 9300),
  log: Rails.env.development?
)
