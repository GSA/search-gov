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

  private

  def set_search_options
    affiliate = Affiliate.find_by_name(params["affiliate"]) rescue nil
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"],
      :affiliate => affiliate,
      :engine => params["engine"]
    }
  end
end
