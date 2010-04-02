class RecallsController < ApplicationController
  def index
    @query = params[:query]
    @page = params[:page] || 1
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @upc = params[:upc]
    @sort = params[:sort] || "score"
    @organization = params[:organization]
    @code = params[:code]
    @search = Recall.search_for(@query, {:start_date => @start_date, :end_date => @end_date, :upc => @upc, :sort => @sort, :organization => @organization, :code => @code}, @page)
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

