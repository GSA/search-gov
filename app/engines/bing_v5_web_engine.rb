class BingV5WebEngine < BingV5Engine
  API_ENDPOINT = '/bing/v5.0/search'.freeze

  self.api_endpoint = API_ENDPOINT
  self.response_parser_class = BingWebResponseParser

  def params
    super.merge({
      responseFilter: 'WebPages,SpellSuggestions',
      textDecorations: options[:enable_highlighting],
    })
  end
end
