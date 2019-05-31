class BingV7WebSearch < BingSearch
  API_ENDPOINT = '/bing/v7.0/search'.freeze
  include BingV7HostedSubscriptionKey

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v7'
  self.response_parser_class = BingWebResponseParser
end
