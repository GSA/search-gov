class ApiController < ApplicationController
  DEFAULT_API_PER_PAGE = 10.freeze
  ssl_allowed :search
  before_filter :load_affiliate

  def search
    @search_options = search_options_from_params(@affiliate, params).merge(
      format: params[:format], index: params[:index], per_page: DEFAULT_API_PER_PAGE, lat_lon: params[:lat_lon])
    @search = ApiSearch.search(@search_options)
    respond_to do |format|
      format.xml { render :xml => @search }
      format.json { params[:callback].blank? ? render(:json => @search) : render(:json => @search, :callback => params[:callback]) }
    end
  end

  private
  def load_affiliate
    @affiliate = Affiliate.find_by_name(params[:affiliate].to_s) if params[:affiliate].present?
    unless @affiliate
      render :text => 'Not Found', :status => 404
      false
    end
  end
end
