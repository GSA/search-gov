class BingV6ImageSearch < BingV6Search
  API_ENDPOINT = '/api/v6/images/search'.freeze

  self.api_endpoint = API_ENDPOINT
  self.response_parser_class = BingV6ImageResponseParser
end
