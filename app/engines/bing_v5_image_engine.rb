# frozen_string_literal: true

class BingV5ImageEngine < BingSearch
  API_HOST = 'https://api.cognitive.microsoft.com'
  API_ENDPOINT = '/bing/v5.0/images/search'
  include BingV5HostedSubscriptionKey

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v5_api'
  self.response_parser_class = BingV5ImageResponseParser

  def self.api_host
    API_HOST
  end
end
