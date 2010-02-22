class ImageSearchesController < SearchesController
  def index
    @search = ImageSearch.new(@search_options)
    @search.run
    handle_affiliate_search
  end
end