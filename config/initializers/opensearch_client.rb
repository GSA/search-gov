# frozen_string_literal: true

require 'elasticsearch'
require 'uri'

host_env = ENV.fetch('OPENSEARCH_SEARCH_HOST', 'http://localhost')
uri = URI.parse(host_env)

# Check if the port was LITERALLY typed into the host string
# If it wasn't, we look to the ENV port or the 9300 default
# We need to do this because we currently have port number in the host string in
# some environments (like CircleCI and ParamStore) but not others (like local/dev)
port = if host_env.match?(%r{:\d+/?$}) 
         uri.port
       else
         ENV['OPENSEARCH_SEARCH_PORT'] || 9300
       end

# NOTE: This is using the Elasticsearch::Client because the opensearch-ruby gem
# has a dependency on a newer version of faraday than is allowed by the
# omniauth_login_dot_gov gem.
#
# The elasticsearch-ruby gem is compatible with OpenSearch.
OPENSEARCH_CLIENT = Elasticsearch::Client.new(
  url: "#{uri.scheme}://#{uri.host}",
  port: port.to_i,
  user: ENV.fetch('OPENSEARCH_SEARCH_USER', 'admin'),
  password: ENV['OPENSEARCH_SEARCH_PASSWORD'],
  log: Rails.env.development?
)
