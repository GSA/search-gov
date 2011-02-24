class ApiController < ApplicationController
  before_filter :verify_api_key_and_load_affiliate

  def search
    @search_options = search_options_from_params(params).merge(:affiliate => @affiliate)
    render :json => ApiSearch.search(@search_options)
  end

  def verify_api_key_and_load_affiliate
    unless user = params[:api_key].present? && User.find_by_api_key(params[:api_key])
      render :text => 'Invalid API Key', :status => 401
      return false
    end

    unless @affiliate = user.affiliates.find_by_name(params[:affiliate_name])
      render :text => 'Unauthorized', :status => 403
      return false
    end
  end

end
