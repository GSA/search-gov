class Sites::DomainsController < Sites::BaseController
  include ActionView::Helpers::TextHelper

  before_filter :setup_site
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
      @site.normalize_site_domains
      @site.autodiscover_homepage_url
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
      redirect_to site_domains_path(@site),
                  flash: { success: "You have updated #{@domain.domain}." }
    else
      render action: :edit
    end
  end

  def destroy
    @domain.destroy
    redirect_to site_domains_path(@site),
                flash: { success: "You have removed #{@domain.domain} from this site." }
  end

  def new_bulk_upload
  end

  def bulk_upload
    result = SiteDomain.process_file(@site, params[:domains_data_file])
    if result[:success]
      redirect_to site_domains_path(@site),
                  flash: { success: "You have added #{pluralize(result[:added], 'domain')} to this site." }
    else
      flash.now[:error] = result[:error_message]
      render action: :new_bulk_upload
    end
  end

  private

  def setup_domain
    @domain = @site.site_domains.find_by_id params[:id]
    redirect_to site_domains_path(@site) unless @domain
  end

  def domain_params
    @domain_params ||= params[:domain].slice(:domain)
  end
end
