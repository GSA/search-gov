class SearchesController < ApplicationController

  before_filter :set_search_options

  def index
    @search = Search.new(@search_options)
    @search.run
  end

  private

  def set_search_options
    @search_options = {
      #:page => params[:page],
      :queryterm => params["queryterm"]
    }
    RAILS_DEFAULT_LOGGER.debug "got #{@search_options[:queryterm]} for search term"
  end
end
