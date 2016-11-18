class Sites::ClonesController < Sites::SetupSiteController

  def new
  end

  def create
    site_cloner = SiteCloner.new(@site, params[:name])
    cloned_instance = site_cloner.clone

    redirect_to site_path(cloned_instance), flash: { success: "Site '#{@site.name}' has been cloned as '#{cloned_instance.name}'" }
  rescue StandardError => e
    flash.now[:error] = e.message
    render action: :new
  end
end
