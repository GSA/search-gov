class Sites::AutodiscoveriesController < Sites::BaseController
  before_filter :setup_site

  def create
    flash = {
      autodiscovery_url: @autodiscovery_url = params.require(:autodiscovery_url)
    }

    begin
      SiteAutodiscoverer.new(@site, @autodiscovery_url).run
      flash[:success] = "Discovery complete for #{@autodiscovery_url}"
    rescue URI::InvalidURIError
      flash[:error] = "Invalid site URL #{@autodiscovery_url}"
    end

    redirect_to site_content_path(@site), flash: flash
  end
end
