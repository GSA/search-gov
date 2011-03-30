class Admin::TopSearchesController < Admin::AdminController
  before_filter :assign_page_title
  def index
    @top_searches = TopSearch.order("position ASC")
    @active_top_searches = TopSearch.find_active_entries
  end
  
  def create
    @top_searches = []
    1.upto(5) do |index|
      top_search = TopSearch.find_by_position(index)
      top_search.query = params["query#{index}"]
      top_search.url = params["url#{index}"].present? ? params["url#{index}"] : nil
      top_search.save
      @top_searches << top_search
    end
    flash[:success] = 'Top Searches were updated successfully.'
    redirect_to admin_top_searches_path
  end

  private
  def assign_page_title
    @page_title = "Top Searches"
  end
end
