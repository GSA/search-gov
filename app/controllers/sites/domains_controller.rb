class Sites::DomainsController < Sites::SetupSiteController
  before_filter :setup_domain, only: [:edit, :update, :destroy]

  def index
    @domains = @site.site_domains
  end

  def new
    @domain = @site.site_domains.build
  end

  def create
    @domain = @site.site_domains.build domain_params
    if @domain.save
      update_site_after_save
      redirect_to site_domains_path(@site),
                  flash: { success: "You have added #{@domain.domain} to this site." }
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @domain.update_attributes domain_params
      update_site_after_save
      redirect_to site_domains_path(@site),
                  flash: { success: "You have updated #{@domain.domain}." }
    else
      render action: :edit
    end
  end

  def destroy
    @domain.destroy
    @site.assign_sitelink_generator_names!
    redirect_to site_domains_path(@site),
                flash: { success: "You have removed #{@domain.domain} from this site." }
  end

  private

  def setup_domain
    @domain = @site.site_domains.find_by_id params[:id]
    redirect_to site_domains_path(@site) unless @domain
  end

  def domain_params
    params.require(:domain).permit(:domain)
  end

  def update_site_after_save
    @site.normalize_site_domains
    @site.assign_sitelink_generator_names!
  end
end
