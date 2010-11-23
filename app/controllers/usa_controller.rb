class UsaController < ApplicationController
  has_mobile_fu

  def show
    @search = Search.new
    @site_page = SitePage.find_by_url_slug(params["url_slug"])
    @title = @site_page.title
  end

end
