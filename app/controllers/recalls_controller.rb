class RecallsController < ApplicationController
  def index
    @query = params[:query]
    @page = params[:page] || 1
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @search = Recall.search_for(@query, @start_date, @end_date, @page)
    respond_to do |format|
      format.json {
        render :json => { :success => { :total => @search.total, :results => @search.results } }
      }
      format.any {
        render :text => 'Not Implemented'
      }
    end
  end
end

