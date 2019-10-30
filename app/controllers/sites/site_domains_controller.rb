class Sites::SiteDomainsController < Sites::SetupSiteController
  include ::Hintable

  before_action :setup_domain, only: [:edit, :update, :destroy]
  before_action :load_hints, only: %i(edit new)

  def index
    @site_domains = @site.site_domains
  end

  def new
    @site_domain = @site.site_domains.build
  end

  def create
    @site_domain = @site.site_domains.build site_domain_params
    if @site_domain.save
      update_site_after_save
      redirect_to site_domains_path(@site),
                  flash: { success: "You have added #{@site_domain.domain} to this site." }
    else
      load_hints
      render action: :new
    end
  end

  def edit
  end

  def update
    if @site_domain.update_attributes site_domain_params
      update_site_after_save
      redirect_to site_domains_path(@site),
                  flash: { success: "You have updated #{@site_domain.domain}." }
    else
      load_hints
      render action: :edit
    end
  end

  def destroy
    @site_domain.destroy
    @site.assign_sitelink_generator_names!
    redirect_to site_domains_path(@site),
                flash: { success: "You have removed #{@site_domain.domain} from this site." }
  end

  private

  def setup_domain
    @site_domain = @site.site_domains.find_by_id params[:id]
    redirect_to site_domains_path(@site) unless @site_domain
  end

  def site_domain_params
    params.require(:site_domain).permit(:domain).to_h
  end

  def update_site_after_save
    @site.normalize_site_domains
    @site.assign_sitelink_generator_names!
  end
end
