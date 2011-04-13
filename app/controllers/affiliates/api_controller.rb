class Affiliates::ApiController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin, :except => :search
  before_filter :setup_affiliate, :except => :search
  before_filter :verify_api_key_and_load_affiliate, :only => :search

  def search
    @search_options = search_options_from_params(params).merge(:affiliate => @affiliate)
    if (params[:callback].blank?)
      render :json => ApiSearch.search(@search_options)
    else
      render :json => "#{params[:callback]}(#{ApiSearch.search(@search_options).to_json})"
    end
  end

  def index
  end

  def verify_api_key_and_load_affiliate
    unless user = params[:api_key].present? && User.find_by_api_key(params[:api_key])
      render :text => 'Invalid API Key', :status => 401
      return false
    end

    unless @affiliate = user.affiliates.find_by_name(params[:affiliate])
      render :text => 'Unauthorized', :status => 403
      return false
    end
  end

end
