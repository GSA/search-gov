class ImageSearchesController < ApplicationController
  layout 'searches'

  before_filter :set_search_options
  before_filter :force_mobile_format
  ssl_allowed :index

  def index
    @search = search_klass.new(@search_options)
    @search.run
    @page_title = @search.query
    set_search_page_title
    @search_vertical = :image
    set_search_params
    SearchImpression.log(@search, @search_vertical, params, request)
    respond_to do |format|
      format.any(:html, :mobile) {}
      format.json { render :json => @search }
    end
  end

  private

  def set_search_options
    @affiliate = Affiliate.find_by_name(filtered_params[:affiliate].to_s) unless filtered_params[:affiliate].blank?
    set_affiliate_based_on_locale_param
    set_locale_based_on_affiliate_locale
    @search_options = {
      :page => filtered_params[:page],
      :per_page => SERP_RESULTS_PER_PAGE,
      :query => sanitize_query(filtered_params[:query]),
      :affiliate => @affiliate
    }
  end

  def filtered_params
    params.permit(:affiliate, :page, :per_page, :query)
  end

  def force_mobile_format
    return if request.format && request.format.json?
    request.format = @affiliate.force_mobile_format? ? :mobile : :html
  end

  def search_klass
    @affiliate.force_mobile_format? ? OdieImageSearch : ImageSearch
  end
end
