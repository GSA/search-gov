class BingV6WebSearch < BingSearch
  API_ENDPOINT = '/api/v6/search'.freeze
  include BingV6ApiHost
  include BingV6Authentication

  self.api_endpoint = API_ENDPOINT
  self.api_cache_namespace = 'bing_v6'
  self.response_parser_class = BingWebResponseParser
end
