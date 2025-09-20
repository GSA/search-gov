# frozen_string_literal: true

require 'elasticsearch'

# NOTE: This is using the Elasticsearch::Client because the opensearch-ruby gem
# has a dependency on a newer version of faraday than is allowed by the
# omniauth_login_dot_gov gem.
#
# The elasticsearch-ruby gem is compatible with OpenSearch.
OPENSEARCH_CLIENT = Elasticsearch::Client.new(
  url: ENV.fetch('OPENSEARCH_HOST', 'http://localhost:9300'),
  user: ENV['OPENSEARCH_USER'],
  password: ENV['OPENSEARCH_PASSWORD'],
  log: Rails.env.development?
)
