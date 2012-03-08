class ImageSearchesController < ApplicationController
  layout 'affiliate'
  
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
    respond_to do |format|
      format.html {}
      format.mobile {}
      format.json { render :json => @search }
    end
  end

  private

  def handle_affiliate_search
    @page_title = params[:staged] ? @affiliate.build_staged_search_results_page_title(params[:query]) : @affiliate.build_search_results_page_title(params[:query])
  end

  def set_search_options
    @affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil    
    @affiliate = (I18n.locale == :en ? Affiliate.find_by_name("usagov") : Affiliate.find_by_name('gobiernousa')) if @affiliate.nil?
    @search_options = {
      :page => [(params[:page] || "1").to_i, 1].max,
      :query => params["query"],
      :affiliate => @affiliate,
      :per_page => 30
    }
  end
end
