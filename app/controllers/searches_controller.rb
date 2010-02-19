class SearchesController < ApplicationController
  before_filter :set_search_options
  has_mobile_fu

  def index
    @search = Search.new(@search_options)
    @search.run
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @page_title = "#{t :search_results_for} #{@affiliate.name}: #{@search.query}"
      render :action => "affiliate_index", :layout => "affiliate"
    end
  end

  def auto_complete_for_search_query
    render :inline => "" and return unless params['query']
    sanitized_query = params['query'].gsub('\\', '')
    pre_filters = ' AND query NOT LIKE "%http:%" AND query NOT LIKE "%intitle:%" AND query NOT LIKE "%site:%" AND query NOT REGEXP "[()\/\"]"'
    conditions = ['query LIKE ? '+pre_filters, sanitized_query + '%' ]
    results = DailyQueryStat.find(:all, :conditions => conditions, :order => 'query ASC', :limit => 15, :select=>"distinct(query) as query")
    @auto_complete_options = BlockWord.filter(results, "query")
    render :inline => "<%= auto_complete_result(@auto_complete_options, 'query', '#{sanitized_query.gsub("'", "\\\\'")}') %>"
  end

  def advanced
  end

  private

  def set_search_options
    affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil
    if affiliate && params["staged"]
      affiliate.domains = affiliate.staged_domains
      affiliate.header = affiliate.staged_header
      affiliate.footer = affiliate.staged_footer
    end
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"] || nil,
      :query_limit => params["query-limit"] || nil,
      :query_quote => params["query-quote"] || nil,
      :query_quote_limit => params["query-quote-limit"] || nil,
      :query_or => params["query-or"] || nil,
      :query_or_limit => params["query-or-limit"] || nil,
      :query_not => params["query-not"] || nil,
      :query_not_limit => params["query-not-limit"] || nil,
      :file_type => params["filetype"] || nil,
      :site_limits => params["sitelimit"] || nil,
      :site_excludes => params["siteexclude"] || nil,
      :filter => params["filter"] || nil,
      :affiliate => affiliate,
      :results_per_page => in_mobile_view? ? (is_device?("iphone") ? 10 : 3) : (params["per-page"].nil? ? nil : (params["per-page"].empty? ? nil : params["per-page"].to_i))
    }
  end
end