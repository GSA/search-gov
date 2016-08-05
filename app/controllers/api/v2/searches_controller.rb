class Api::V2::SearchesController < ApplicationController
  respond_to :json

  skip_before_filter :ensure_proper_protocol
  skip_before_filter :set_default_locale
  before_filter :require_ssl
  before_filter :validate_search_options
  before_filter :handle_query_routing
  after_filter :log_search_impression

  def blended
    @search = ApiBlendedSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def azure
    @search = ApiAzureSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def azure_web
    @search = ApiAzureCompositeWebSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def azure_image
    @search = ApiAzureCompositeImageSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def bing
    @search = ApiBingSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def gss
    @search = ApiGssSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def i14y
    @search = ApiI14ySearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def video
    @search = ApiVideoSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def docs
    @document_collection = (DocumentCollection.find(@search_options.dc) rescue nil)
    if @document_collection and @document_collection.too_deep_for_bing?
      @search = ApiGoogleDocsSearch.new @search_options.attributes
    else
      affiliate = @search_options.site
      klass = "Api#{affiliate.search_engine}DocsSearch".constantize
      @search = klass.new @search_options.attributes
    end
    @search.run
    respond_with @search
  end

  private

  def require_ssl
    respond_with(*ssl_required_response) unless request_ssl? || valid_search_consumer_access_key?
  end

  def request_ssl?
    Rails.env.production? ? request.ssl? : true
  end

  def ssl_required_response
    [{ errors: ['HTTPS is required'] }, { status: 400 }]
  end

  def handle_query_routing
    return unless search_params[:query].present? and query_routing_is_enabled?
    affiliate = @search_options.site
    routed_query = affiliate.routed_queries
                     .joins(:routed_query_keywords)
                     .where(routed_query_keywords:{keyword: search_params[:query]})
                     .first
    respond_with({ redirect: routed_query[:url] }, { status: 200 }) unless routed_query.nil?
  end

  def query_routing_is_enabled?
    search_params[:routed] == 'true'
  end

  def valid_search_consumer_access_key?
    params[:sc_access_key] == SC_ACCESS_KEY
  end

  def search_params
    @search_params ||= params.permit(:access_key,
                                     :affiliate,
                                     :dc,
                                     :api_key,
                                     :cx,
                                     :enable_highlighting,
                                     :format,
                                     :limit,
                                     :offset,
                                     :query,
                                     :sort_by,
                                     :sc_access_key,
                                     :routed)
  end

  def validate_search_options
    @search_options = search_options_validator_klass.new search_params
    unless @search_options.valid? && @search_options.valid?(:affiliate)
      obfuscate_sc_access_key_error if sc_access_key_error.present?
      respond_with({ errors: @search_options.errors.full_messages }, { status: 400 })
    end
  end

  def search_options_validator_klass
    case action_name.to_sym
    when :azure then Api::CommercialSearchOptions
    when :azure_web then Api::AzureCompositeWebSearchOptions
    when :azure_image then Api::AzureCompositeImageSearchOptions
    when :bing then Api::SecretAPISearchOptions
    when :blended, :video then Api::NonCommercialSearchOptions
    when :gss then Api::GssSearchOptions
    when :i14y then Api::SearchOptions
    when :docs then Api::DocsSearchOptions
    end
  end

  def sc_access_key_error
    @search_options.errors[:sc_access_key]
  end

  def obfuscate_sc_access_key_error
    @search_options.errors.delete :sc_access_key
    @search_options.errors[:hidden_key] = 'is required'
  end

  def log_search_impression
    SearchImpression.log(@search, action_name, search_params, request)
  end
end
