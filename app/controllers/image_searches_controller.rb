class ImageSearchesController < ApplicationController
  layout 'searches'

  before_filter :set_search_options
  ssl_allowed :index

  def index
    @search = ImageSearch.new(@search_options)
    @search.run
    @page_title = @search.query
    set_search_page_title
    @search_vertical = :image
    set_search_params
    respond_to do |format|
      format.html {}
      format.json { render :json => @search }
    end
  end

  private

  def set_search_options
    @affiliate = Affiliate.find_by_name(params[:affiliate].to_s) unless params[:affiliate].blank?
    set_affiliate_based_on_locale_param
    set_locale_based_on_affiliate_locale
    @search_options = {
      :page => params[:page],
      :per_page => SERP_RESULTS_PER_PAGE,
      :query => sanitize_query(params["query"]),
      :affiliate => @affiliate
    }
  end
end
