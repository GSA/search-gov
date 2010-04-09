class RecallsController < ApplicationController
  def index
    valid_options = %w{start_date end_date upc sort code organization make model year}
    search = Recall.search_for(params[:query],
                               params.reject {|k,| !valid_options.include?k.to_s},
                               params[:page])
    respond_to do |format|
      format.json {
        render :json => { :success => { :total => search.total, :results => search.results } }
      }
      format.any {
        render :text => 'Not Implemented'
      }
    end
  end
end

