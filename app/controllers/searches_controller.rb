class SearchesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :handle_old_advanced_form, :only => [ :index ]
  before_filter :grab_format
  before_filter :set_search_options
  has_mobile_fu
  before_filter :adjust_mobile_mode
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6
  ssl_allowed :auto_complete_for_search_query

  def index
    @search = Search.new(@search_options)
    @search.run
    @page_title = @search.query
    handle_affiliate_search
    if @search_options[:affiliate]
      render :action => "affiliate_index", :layout => "affiliate"
    else
      respond_to do |format|
        format.html
        format.mobile
        format.json { render :json => @search }
      end
    end
  end

  def auto_complete_for_search_query
    query = params["mode"] == "jquery" ? params["q"] : params["query"]
    render :inline => "" and return unless query
    sanitized_query = query.gsub('\\', '')
    @auto_complete_options = Search.suggestions(nil, sanitized_query, is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE)
    if params["mode"] == "jquery"
      render :json => "#{params['callback']}(#{@auto_complete_options.map{|option| option.phrase }.to_json})"
    else
      render :inline => "<%= auto_complete_result(@auto_complete_options, 'phrase', '#{sanitized_query.gsub("'", "\\\\'")}') %>"
    end
  end

  def advanced
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @scope_id = @search_options[:scope_id]
      render :layout => "affiliate"
    end
  end
  
  def top_searches
    @top_searches = TopSearch.find(:all, :limit => 5, :order => 'position asc')
    render :layout => false
  end

  private

  def handle_affiliate_search
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @scope_id = @search_options[:scope_id]
      @page_title = "#{t :search_results_for} #{@affiliate.name}: #{@search.query}"
    end
  end

  def handle_old_advanced_form
    if params["form"] == "advanced-firstgov"
      redirect_to advanced_search_path(params.merge(:controller => "searches", :action => "advanced"))
    end
  end

  def grab_format
    @original_format = request.format
  end

  # TODO This could be cleaned up into search.rb
  def set_search_options
    affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil
    if affiliate && params["staged"]
      affiliate.domains = affiliate.staged_domains
      affiliate.header = affiliate.staged_header
      affiliate.footer = affiliate.staged_footer
    end
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"],
      :query_limit => params["query-limit"],
      :query_quote => params["query-quote"],
      :query_quote_limit => params["query-quote-limit"],
      :query_or => params["query-or"],
      :query_or_limit => params["query-or-limit"],
      :query_not => params["query-not"],
      :query_not_limit => params["query-not-limit"],
      :file_type => params["filetype"],
      :site_limits => params["sitelimit"],
      :site_excludes => params["siteexclude"],
      :filter => params["filter"],
      :fedstates => params["fedstates"] || nil,
      :affiliate => affiliate,
      :scope_id => params["scope_id"] || nil,
      :results_per_page => params["per-page"],
      :enable_highlighting => params["hl"].present? && params["hl"] == "false" ? false : true
    }
  end

  def adjust_mobile_mode
    request.format = :html if @search_options[:affiliate].present? or is_advanced_search?
    request.format = :json if @original_format == 'application/json' and @search_options[:affiliate].blank?
  end

  def is_advanced_search?
    params[:action] == "advanced"
  end

end
