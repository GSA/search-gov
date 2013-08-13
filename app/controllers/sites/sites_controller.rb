class Sites::SitesController < Sites::BaseController
  before_filter :setup_site

  def show
    @dashboard = Dashboard.new(@site)
  end
end
