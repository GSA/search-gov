class ImageSearchesController < ApplicationController
  before_filter :set_search_options
  ssl_allowed :index
  has_mobile_fu

  def index
    redirect_to images_path and return if @search_options[:query].blank? and !in_mobile_view?
    @search = ImageSearch.new(@search_options)
    @search.run
    @page_title = @search.query
    handle_affiliate_search
    @search_vertical = :image
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
      :page => [(params[:page] || "1").to_i, 1].max,
      :query => params["query"],
      :affiliate => affiliate,
      :per_page => 30
    }
  end
end
