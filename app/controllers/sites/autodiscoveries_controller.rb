class Sites::AutodiscoveriesController < Sites::BaseController
  before_filter :setup_site

  def create
    SiteAutodiscoverer.new(@site).run
    redirect_to site_path(@site), flash: { success: "Discovery complete for '#{@site.display_name}'" }
  end

end
