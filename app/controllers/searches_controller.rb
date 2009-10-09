class SearchesController < ApplicationController
  before_filter :set_search_options

  def index
    @search = Search.new(@search_options)
    @search.run
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @page_title = "Search results for #{@affiliate.name}: #{@search.query}"
      render :action => "affiliate_index", :layout => "affiliate"
    end
  end

  def auto_complete_for_search_query
    conditions = ['query LIKE ?', params['query'] + '%' ]
    @auto_complete_options = DailyQueryStat.find(:all, :conditions => conditions, :order => 'query ASC', :limit => 15, :select=>"distinct(query) as query")
    render :inline => "<%= auto_complete_result(@auto_complete_options, 'query', '#{params['query']}') %>"
  end

  private

  def set_search_options
    affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"],
      :affiliate => affiliate,
      :engine => params["engine"]
    }
  end
end
