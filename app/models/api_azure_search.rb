class ApiAzureSearch < Search
  include DefaultModuleTaggable
  include CommercialSearch
  include Govboxable
  include Api::V2::SearchAsJson

  HIGHLIGHT_OPTIONS = {
    pre_tags: ["\ue000"],
    post_tags: ["\ue001"]
  }.freeze

  self.default_module_tag = 'AWEB'.freeze

  attr_reader :next_offset

  def initialize(options)
    @affiliate = options[:affiliate]
    @highlight_options = options.slice(:highlighting).merge(HIGHLIGHT_OPTIONS)
    @modules = []
    @offset = options[:offset]
    @query = options[:query]
    @results = []
    @search_engine = instantiate_engine(options)
  end

  protected

  def instantiate_engine(options)
    formatted_query_instance = AzureFormattedQuery.new(@query, domains_scope_options)
    @formatted_query = formatted_query_instance.query
    engine_options = options.slice(:highlighting, :limit, :next_offset_within_limit, :offset)
    engine_options.merge!(language: @affiliate.locale,
                          password: options[:api_key],
                          query: @formatted_query)
    AzureWebEngine.new engine_options
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
