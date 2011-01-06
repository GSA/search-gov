class Admin::TopSearchesController < Admin::AdminController
  def index
    @top_searches = TopSearch.find(:all, :order => "position ASC")
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
    render :action => :index
  end  
end
