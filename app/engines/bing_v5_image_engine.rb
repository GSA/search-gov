class BingV5ImageEngine < BingV5Engine
  API_ENDPOINT = '/bing/v5.0/images/search'.freeze

  self.api_endpoint = API_ENDPOINT
  self.response_parser_class = BingImageResponseParser
end
