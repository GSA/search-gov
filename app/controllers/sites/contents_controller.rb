class Sites::ContentsController < Sites::SetupSiteController
  def show
    @autodiscovery_url = flash[:autodiscovery_url] || @site.default_autodiscovery_url
  end
end
