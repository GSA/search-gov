class BingV6WebSearch < BingV6Search
  API_ENDPOINT = '/api/v6/search'.freeze

  self.api_endpoint = API_ENDPOINT
  self.response_parser_class = BingV6WebResponseParser

  def params
    super.merge({
      responseFilter: 'WebPages,SpellSuggestions',
      textDecorations: options[:enable_highlighting],
    })
  end
end
