class ApiCommercialSearch < Search
  include DefaultModuleTaggable
  include SearchOnCommercialEngine
  include Govboxable
  include Api::V2::SearchAsJson

  attr_reader :next_offset

  def initialize(options)
    @affiliate = options[:affiliate]
    @highlight_options = build_highlighting_options options
    @modules = []
    @offset = options[:offset]
    @query = options[:query]
    @results = []
    @search_engine = instantiate_engine(options)
    @spelling_suggestion_eligible = !SuggestionBlock.exists?(query: @query)
  end

  def diagnostics_label
    default_module_tag
  end

  protected

  def build_highlighting_options(options)
    { highlighting: options[:enable_highlighting] }.
      merge(Api::V2::HighlightOptions::DEFAULT)
  end

  def instantiate_engine(_options)
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build @affiliate, nil
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
