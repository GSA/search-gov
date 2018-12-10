class BingV7ImageSearch < BingSearch
  API_ENDPOINT = '/bing/v7.0/images/search'.freeze
  include BingV7HostedSubscriptionKey

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v7'
  self.response_parser_class = BingImageResponseParser
end
