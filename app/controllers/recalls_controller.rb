class RecallsController < ApplicationController
  before_filter :validate_api_key
  before_filter :setup_params
  before_filter :verify_params
  before_filter :convert_date_range_to_start_and_end_dates
  ssl_allowed :index, :search, :api_search


  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
  MAX_PAGES = 100
  RECALLS_CACHE_DURATION_IN_SECONDS = 60 * 30
  VALID_OPTIONS = %w{start_date end_date date_range upc sort code organization make model year food_type}

  def index
    @latest_recalls = Recall.search_for("", {:sort => "date"})
    @search_vertical = :recall
    respond_to do |format|
      format.html
      format.rss
    end
  end

  def search
    respond_to do |format|
      format.html {
        @search_vertical = :recall
        @query = params[:query] || ""

        redirect_to recalls_path and return if @query.blank?

        @valid_params[:sort] = 'rel' if params[:sort].blank?
        @page = params[:page]
        @page = MAX_PAGES if @page && @page.to_i > MAX_PAGES
        @search = Recall.search_for(@query, @valid_params, @page)
        if @search
          pagination_total = [@search.results.total_pages, MAX_PAGES].min
          @paginated_results = WillPaginate::Collection.create(@search.hits.current_page, @search.hits.per_page, pagination_total * @search.hits.per_page) { |pager| pager.replace(@search.hits) }
        end
        @page_title = @query
        log_serp_impressions
      }
      format.json {
        api_search
      }
    end
  end

  def api_search
    if @error_message
      render :json => { :error => @error_message }
    else
      query = params[:query]
      page = params[:page]
      cache_key = [@valid_params.to_s, query, page].join(':')
      success_total_results_json = @@redis.get(cache_key) rescue nil
      if success_total_results_json.nil?
        search = Recall.search_for(query, @valid_params, page) || Struct.new(:total, :results).new(0, [])
        success_total_results_json = {:success => {:total => search.total, :results => search.results}}.to_json
        @@redis.setex(cache_key, RECALLS_CACHE_DURATION_IN_SECONDS, success_total_results_json) rescue nil
      end
      render :text => success_total_results_json, :content_type => "application/json"
    end
  end

  private

  def validate_api_key
    render :text => 'Invalid API Key', :status => 401 if request.format == 'json' and params[:api_key].present? and User.find_by_api_key(params[:api_key]).nil?
  end

  def setup_params
    @valid_params = params.reject { |k,| !VALID_OPTIONS.include? k.to_s }
  end

  def verify_params
    @error_message = nil
    @error_message = "Invalid date" unless date_str_valid_or_nil?(params[:start_date]) and date_str_valid_or_nil?(params[:end_date])
    @error_message = "Invalid organization" if params[:organization] and not Recall::VALID_ORGANIZATIONS.include? params[:organization]
    @error_message = "Invalid code" if params[:code] and not %w{E V I T C X}.include? params[:code]
    @error_message = "Invalid year" if params[:year] and not params[:year] =~ /^\d{4}$/
    @error_message = "Invalid page" if params[:page] and not params[:page] =~ /^\d+$/
    @error_message = "Invalid date range" if params[:date_range] and not %w{last_30 last_90 current_year last_year}.include?(params[:date_range])
  end

  def date_str_valid_or_nil?(str)
    return true if str.nil?
    parsed = Date.parse(str) rescue nil
    !parsed.nil?
  end

  def convert_date_range_to_start_and_end_dates
    if params[:date_range].present?
      if params[:date_range] == "last_30"
        @valid_params[:start_date], @valid_params[:end_date] = Date.current - 30.days, Date.current
      elsif params[:date_range] == "last_90"
        @valid_params[:start_date], @valid_params[:end_date] = Date.current - 90.days, Date.current
      elsif params[:date_range] == "current_year"
        @valid_params[:start_date], @valid_params[:end_date] = Date.parse("#{Date.current.year}-01-01"), Date.current
      elsif params[:date_range] = "last_year"
        @valid_params[:start_date], @valid_params[:end_date] = Date.parse("#{Date.current.year - 1}-01-01"), Date.parse("#{Date.current.year - 1}-12-31")
      end
    end
  end

  def log_serp_impressions
    modules = []
    modules << "RECALL" unless @search.nil? or @search.total.zero?
    QueryImpression.log(:recall, Affiliate::USAGOV_AFFILIATE_NAME, @query, modules)
  end
end
