class RecallsController < ApplicationController
  def index
    valid_options = %w{start_date end_date upc sort code organization make model year food_type}
    begin
      search = Recall.search_for(params[:query],
                                 params.reject {|k,| !valid_options.include?k.to_s},
                                 params[:page])
    rescue Exception => exception
    end
    respond_to do |format|
      format.json {
        if exception
          render :json => { :error => exception.to_s }
        else
          render :json => { :success => { :total => search.total, :results => search.results } }
        end
      }
      format.any {
        render :text => 'Not Implemented'
      }
    end
  end
end

