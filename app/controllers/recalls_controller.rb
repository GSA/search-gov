class RecallsController < ApplicationController
  def index
    @query = params[:query]
    @page = params[:page] || 1
    @search = Recall.search_for(@query, @page)
    render :json => { :total => @search.total, :results => @search.results }
  end
end

