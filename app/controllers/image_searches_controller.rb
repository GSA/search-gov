class ImageSearchesController < ApplicationController
  include MobileFriendlyController

  layout 'searches'

  before_filter :set_search_options
  before_filter :force_request_format
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
        affiliate: @affiliate,
        cr: filtered_params[:cr],
        page: filtered_params[:page],
        query: sanitize_query(filtered_params[:query])
    }
  end

  def filtered_params
    params.permit(:affiliate, :cr, :m, :page, :per_page, :query, :utf8)
  end

  def search_klass
    @affiliate.force_mobile_format? ? ImageSearch : LegacyImageSearch
  end
end
