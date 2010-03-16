class SearchesController < ApplicationController
  before_filter :set_search_options
  has_mobile_fu
  before_filter :adjust_mobile_mode
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6

  def index
    @search = Search.new(@search_options)
    @search.run
    handle_affiliate_search
  end

  def auto_complete_for_search_query
    render :inline => "" and return unless params['query']
    sanitized_query = params['query'].gsub('\\', '')
    @auto_complete_options = Search.suggestions(sanitized_query, is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE)
    render :inline => "<%= auto_complete_result(@auto_complete_options, 'phrase', '#{sanitized_query.gsub("'", "\\\\'")}') %>"
  end

  private

  def handle_affiliate_search
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @page_title = "#{t :search_results_for} #{@affiliate.name}: #{@search.query}"
      render :action => "affiliate_index", :layout => "affiliate"
    end
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
      :results_per_page => in_mobile_view? ? (is_device?("iphone") ? 10 : 3) : (params["per-page"].blank? ? nil : params["per-page"].to_i)
    }
  end

  def adjust_mobile_mode
    request.format= :html if @search_options[:affiliate].present? or is_advanced_search?
  end

  def is_advanced_search?
    params[:action] == "advanced"
  end
end
