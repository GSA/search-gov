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

  def diagnostics_label
    default_module_tag
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

  def handle_response(response)
    return unless response
    @results = response.results
    @next_offset = response.next_offset
    true
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(@query,
                                @affiliate,
                                nil,
                                @highlight_options) if first_page?
  end

  def first_page?
    @offset.zero?
  end

  def as_json_build_snippet(description)
    description
  end

  def as_json_append_govbox_set(hash)
    super do
      hash[:recent_video_news] = video_news_items ? as_json_video_news(video_news_items.results) : []
      hash[:recent_news] = news_items ? as_json_recent_news : []
    end
  end

  def as_json_recent_news
    news_items.results.map { |news_item| as_json_news_item news_item }
  end

  def log_serp_impressions
    @modules << default_module_tag if @results.present?
    @modules |= @govbox_set.modules if @govbox_set
  end
end
