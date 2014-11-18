class Api::V2::SearchesController < SslController
  respond_to :json

  skip_before_filter :set_default_locale, :show_searchbox
  before_filter :validate_params
  before_filter :set_affiliate, :set_locale_based_on_affiliate_locale

  def index
    api_params = @param_validator.valid_params.merge(affiliate: @affiliate)
    @search = ApiBlendedSearch.new api_params
    @search.run
    respond_with @search
  end

  private

  def set_affiliate
    unless search_params[:affiliate].blank?
      @affiliate = Affiliate.find_by_name(search_params[:affiliate])
    end
    respond_with(*affiliate_not_found_response) unless @affiliate
  end

  def search_params
    @search_params ||= params.permit(:affiliate,
                                     :enable_highlighting,
                                     :format,
                                     :limit,
                                     :offset,
                                     :query)
  end

  def affiliate_not_found_response
    [{ errors: ['affiliate not found'] }, { status: 404 }]
  end

  def validate_params
    @param_validator = Api::SearchParamValidator.new search_params
    unless @param_validator.valid?
      respond_with({ errors: @param_validator.errors }, { status: 400 })
    end
  end
end
