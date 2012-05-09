class Affiliates::TopSearchesController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def index
    @top_searches = @affiliate.top_searches
    @active_top_searches = @affiliate.active_top_searches
    render 'admin/top_searches/index'
  end

  def create
    @affiliate.update_attributes(:top_searches_label => params[:top_searches_label].blank? ? 'Search Trends' : params[:top_searches_label])
    @top_searches = []
    1.upto(5) do |index|
      top_search = @affiliate.top_searches.find_or_initialize_by_position(index)
      top_search.query = params["query#{index}"]
      top_search.url = params["url#{index}"].present? ? params["url#{index}"] : nil
      top_search.save
      @top_searches << top_search
    end
    flash[:success] = 'Top Searches were updated successfully.'
    redirect_to affiliate_top_searches_path
  end
end