class RecallsController < ApplicationController
  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
  RECALLS_CACHE_DURATION_IN_SECONDS = 60 * 30

  def index
    valid_options = %w{start_date end_date upc sort code organization make model year food_type}
    valid_params = params.reject { |k,| !valid_options.include? k.to_s }
    error_message = verify_params(valid_params.merge(:page => params[:page]))
    if error_message
      render :json => {:error => error_message}
      return
    end

    query = params[:query]
    page = params[:page]
    cache_key = [valid_params.to_s, query, page].join(':')
    success_total_results_json = @@redis.get(cache_key) rescue nil
    if success_total_results_json.nil?
      search = Recall.search_for(query, valid_params, page)
      success_total_results_json = {:success => {:total => search.total, :results => search.results}}.to_json
      @@redis.setex(cache_key, RECALLS_CACHE_DURATION_IN_SECONDS, success_total_results_json) rescue nil
    end

    respond_to do |format|
      format.json { render :text => success_total_results_json, :content_type => "application/json" }
      format.any { render :text => 'Not Implemented' }
    end
  end

  private
  def verify_params(p)
    error_message = nil
    error_message = "invalid date" if (p[:start_date] and not p[:start_date] =~ /^\d{4}-\d{1,2}-\d{1,2}$/) or (p[:end_date] and not p[:end_date] =~ /^\d{4}-\d{1,2}-\d{1,2}$/)
    error_message = "invalid organization" if p[:organization] and not Recall::VALID_ORGANIZATIONS.include? p[:organization]
    error_message = "invalid code" if p[:code] and not %w{E V I T C X}.include? p[:code]
    error_message = "invalid year" if p[:year] and not p[:year] =~ /^\d{4}$/
    error_message = "invalid page" if p[:page] and not p[:page] =~ /^\d+$/
    return error_message
  end
end

