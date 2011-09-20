class ApiController < ApplicationController
  before_filter :verify_api_key_and_load_affiliate

  def search
    @search_options = search_options_from_params(params).merge(:affiliate => @affiliate, :format => params[:format])
    @search = ApiSearch.search(@search_options)
    respond_to do |format|
      format.xml { render :xml => @search }
      format.json { params[:callback].blank? ? render(:json => @search) : render(:json => @search, :callback => params[:callback]) }
    end
  end

  private
  def verify_api_key_and_load_affiliate
    unless user = params[:api_key].present? && User.find_by_api_key(params[:api_key])
      render :text => 'Invalid API Key', :status => 401
      return false
    end

    unless @affiliate = user.affiliates.find_by_name(params[:affiliate])
      render :text => 'Unauthorized', :status => 403
      false
    end
  end

end
