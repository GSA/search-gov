class ApiController < ApplicationController
  before_filter :load_affiliate

  def search
    @search_options = search_options_from_params(@affiliate, params).merge(:format => params[:format], :index => params[:index])
    @search = ApiSearch.search(@search_options)
    respond_to do |format|
      format.xml { render :xml => @search }
      format.json { params[:callback].blank? ? render(:json => @search) : render(:json => @search, :callback => params[:callback]) }
    end
  end

  private
  def load_affiliate
    unless @affiliate = Affiliate.find_by_name(params[:affiliate])
      render :text => 'Not Found', :status => 404
      false
    end
  end
end
