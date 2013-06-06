class ImageSearchesController < ApplicationController
  layout 'searches'

  before_filter :set_search_options
  ssl_allowed :index
  has_mobile_fu

  def index
    @search = ImageSearch.new(@search_options)
    @search.run
    @page_title = @search.query
    handle_affiliate_search
    @search_vertical = :image
    set_search_params
    respond_to do |format|
      format.html {}
      format.mobile {}
      format.json { render :json => @search }
    end
  end

  private

  def handle_affiliate_search
    @page_title = params[:staged] ? @affiliate.build_staged_search_results_page_title(@page_title) : @affiliate.build_search_results_page_title(@page_title)
  end

  def set_search_options
    @affiliate = Affiliate.find_by_name(params[:affiliate].to_s) unless params[:affiliate].blank?
    set_affiliate_based_on_locale_param
    set_locale_based_on_affiliate_locale
    @search_options = {
      :page => params[:page],
      :query => sanitize_query(params["query"]),
      :affiliate => @affiliate
    }
  end
end
