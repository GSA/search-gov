class ApiCommercialSearch < Search
  include DefaultModuleTaggable
  include SearchOnCommercialEngine
  include Govboxable
  include Api::V2::SearchAsJson

  HIGHLIGHT_OPTIONS = {
    pre_tags: ["\ue000"],
    post_tags: ["\ue001"]
  }.freeze

  attr_reader :next_offset

  def initialize(options)
    @affiliate = options[:affiliate]
    @highlight_options = build_highlighting_options options
    @modules = []
    @offset = options[:offset]
    @query = options[:query]
    @results = []
    @search_engine = instantiate_engine(options)
  end

  protected

  def build_highlighting_options(options)
    { highlighting: options[:enable_highlighting] }.merge(HIGHLIGHT_OPTIONS)
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
  end

  def build_snippet(description)
    description
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

  def log_serp_impressions
    @modules << default_module_tag if @results.present?
    @modules |= @govbox_set.modules if @govbox_set
  end
end
