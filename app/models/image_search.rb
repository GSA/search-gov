require 'forwardable'

class ImageSearch
  extend Forwardable
  include Pageable

  self.default_per_page = 20

  attr_reader :affiliate,
              :error_message,
              :module_tag,
              :modules,
              :query,
              :queried_at_seconds,
              :spelling_suggestion_eligible,
              :uses_cr

  def initialize(options = {})
    @options = options
    initialize_pageable_attributes @options

    @affiliate = @options[:affiliate]
    @modules = []
    @queried_at_seconds = Time.now.to_i
    @query = @options[:query]
    @uses_cr = @options[:cr].eql?('true') || @affiliate.has_no_social_image_feeds?
    @search_instance = initialize_search_instance(@uses_cr)
    @spelling_suggestion_eligible = !SuggestionBlock.exists?(query: @query)
  end

  def_instance_delegators :@search_instance,
                          :diagnostics,
                          :endrecord,
                          :results,
                          :startrecord,
                          :total

  def run
    if @query.present?
      @search_instance.run

      if results.blank? && (@page == 1) && !@uses_cr && @affiliate.is_bing_image_search_enabled?
        @search_instance = initialize_search_instance(true)
        @search_instance.run
      end

      assign_module_tag if results.present?
    else
      @error_message = (I18n.translate :empty_query)
    end

  end

  def as_json(options = {})
    if @error_message
      { error: @error_message }
    else
      { total: total,
        startrecord: startrecord,
        endrecord: endrecord,
        results: results }
    end
  end

  def spelling_suggestion
    @search_instance.spelling_suggestion if @spelling_suggestion_eligible
  end

  def commercial_results?
    %W(AIMAG IMAG).include? module_tag
  end

  protected

  def initialize_search_instance(uses_cr)
    params = search_params(uses_cr)
    uses_cr ? search_engine_adapter(params) : OdieImageSearch.new(params)
  end

  def search_params(uses_cr)
    params = @options.slice(:affiliate, :query).merge(page: @page,
                                                      per_page: @per_page)
    params[:skip_log_serp_impressions] = true unless uses_cr
    params
  end

  def search_engine_adapter(options)
    SearchEngineAdapter.new engine_klass, options
  end

  def engine_klass
    if @affiliate.search_engine.start_with?('Bing')
      "#{@affiliate.search_engine}ImageSearch".constantize
    else
      latest_bing_image_search_class
    end
  end

  def latest_bing_image_search_class
    BingV6ImageSearch
  end

  def assign_module_tag
    @module_tag = @search_instance.default_module_tag
    @modules << @module_tag
    @modules << @search_instance.default_spelling_module_tag unless @search_instance.spelling_suggestion.nil?
  end

end
