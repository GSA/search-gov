class ApiCommercialSearch < Search
  include DefaultModuleTaggable
  include SearchOnCommercialEngine
  include Govboxable
  include Api::V2::SearchAsJson

  BING_V5_KEY_REGEX = /\A[0-9a-f]{32}\z/i

  attr_reader :api_key
  attr_reader :next_offset

  def initialize(options)
    @affiliate = options[:affiliate]
    @api_key = options[:api_key]
    @highlight_options = build_highlighting_options options
    @modules = []
    @offset = options[:offset]
    @query = build_query(options)
    @results = []
    @search_engine = instantiate_engine(options)
    @spelling_suggestion_eligible = !SuggestionBlock.exists?(query: @query)
  end

  protected

  def is_api_key_bing_v5?
    api_key =~ BING_V5_KEY_REGEX
  end

  def build_highlighting_options(options)
    { highlighting: options[:enable_highlighting] }.
      merge(Api::V2::HighlightOptions::DEFAULT)
  end

  def instantiate_engine(_options)
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate, site_limits: nil)
  end
end
