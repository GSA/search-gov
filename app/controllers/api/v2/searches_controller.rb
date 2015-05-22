class Api::V2::SearchesController < ApplicationController
  respond_to :json

  skip_before_filter :ensure_proper_protocol
  skip_before_filter :set_default_locale
  before_filter :require_ssl
  before_filter :validate_search_options
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

  def gss
    @search = ApiGssSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  def video
    @search = ApiVideoSearch.new @search_options.attributes
    @search.run
    respond_with @search
  end

  private

  def require_ssl
    respond_with(*ssl_required_response) unless request_ssl?
  end

  def request_ssl?
    Rails.env.production? ? request.ssl? : true
  end

  def ssl_required_response
    [{ errors: ['HTTPS is required'] }, { status: 400 }]
  end

  def search_params
    @search_params ||= params.permit(:access_key,
                                     :affiliate,
                                     :api_key,
                                     :cx,
                                     :enable_highlighting,
                                     :format,
                                     :limit,
                                     :offset,
                                     :query,
                                     :sort_by)
  end

  def validate_search_options
    @search_options = search_options_validator_klass.new search_params
    unless @search_options.valid? && @search_options.valid?(:affiliate)
      respond_with({ errors: @search_options.errors.full_messages }, { status: 400 })
    end
  end

  def search_options_validator_klass
    case action_name.to_sym
    when :azure then Api::CommercialSearchOptions
    when :blended, :video then Api::NonCommercialSearchOptions
    when :gss then Api::GssSearchOptions
    end
  end

  def log_search_impression
    SearchImpression.log(@search, action_name, search_params, request)
  end
end
