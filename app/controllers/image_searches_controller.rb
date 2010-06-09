class ImageSearchesController < ApplicationController
  before_filter :set_search_options

  def index
    @search = ImageSearch.new(@search_options)
    @search.run
    respond_to do |format|
      format.html
      format.mobile
      format.json { render :json => @search }
    end
  end

  private
  def set_search_options
    @search_options = {
      :page => (params[:page].to_i - 1),
      :query => params["query"],
      :results_per_page => 30
    }
  end

end