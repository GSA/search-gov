class Sites::AutodiscoveriesController < Sites::BaseController
  before_action :setup_site

  def create
    flash = {
      autodiscovery_url: @autodiscovery_url = params.require(:autodiscovery_url)
    }

    begin
      site_autodiscoverer = SiteAutodiscoverer.new(@site, @autodiscovery_url)
      site_autodiscoverer.run
      flash[:success] = render_to_string(:partial => '/shared/autodiscovery',
                                         :locals => {
                                           autodiscovery_url: @autodiscovery_url,
                                           discovered_resources: site_autodiscoverer.discovered_resources
                                         }).html_safe
    rescue URI::InvalidURIError
      flash[:error] = "Invalid site URL #{@autodiscovery_url}"
    end

    redirect_to site_content_path(@site), flash: flash
  rescue ActionController::ParameterMissing
    head :bad_request
  end

end
