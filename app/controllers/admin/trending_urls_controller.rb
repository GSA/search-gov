class Admin::TrendingUrlsController < Admin::AdminController

  def index
    @page_title = 'Trending URLs'
    @trending_urls = TrendingUrl.all
  end
end