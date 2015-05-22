class Admin::CompareSearchResultsController < Admin::AdminController
  def index
    @page_title = 'Compare Search Results'
    @affiliate_picklist = Affiliate.select(:name).order(:name).collect{|aff| [aff.name, aff.name]}
    if params[:affiliate_pick]
      @affiliate_pick = params[:affiliate_pick]
      @query = params[:query]
      @affiliate = Affiliate.find_by_name(params[:affiliate_pick])
      @search_options = search_options_from_params
      @web_search = WebSearch.new(@search_options)
      @odie_search = OdieSearch.new(@search_options)
      @web_search.run
      @odie_search.run
    end
  end

end
