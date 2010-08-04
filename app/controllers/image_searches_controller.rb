class ImageSearchesController < ApplicationController
  before_filter :set_search_options

  def index
    @search = ImageSearch.new(@search_options)
    @search.run
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

  private
    
  def handle_affiliate_search
    if @search_options[:affiliate]
      @affiliate = @search_options[:affiliate]
      @scope_id = @search_options[:scope_id]
      @page_title = "#{t :image_search_results_for} #{@affiliate.name}: #{@search.query}"
    end
  end
  
  def set_search_options
    affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"],
      :affiliate => affiliate,
      :scope_id => params["scope_id"] || nil,
      :results_per_page => 30
    }
  end

end