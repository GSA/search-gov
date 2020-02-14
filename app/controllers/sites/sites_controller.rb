class Sites::SitesController < Sites::BaseController
  before_action :setup_site, only: [:show, :pin, :destroy]

  def index
    if current_user.is_affiliate_admin? and current_user.default_affiliate
      redirect_to(site_path(current_user.default_affiliate))
    elsif current_user.is_affiliate? and current_user.affiliates.exists?(current_user.default_affiliate_id)
      redirect_to(site_path(current_user.default_affiliate))
    elsif current_user.affiliates.first
      redirect_to(site_path(current_user.affiliates.first))
    else
      redirect_to(new_site_path)
    end
  end

  def show
    @dashboard = RtuDashboard.new(@site, Date.current, @current_user.sees_filtered_totals?)
  end

  def new
    @site = Affiliate.new
    @site.site_domains.build
  end

  def create
    @site = Affiliate.new(site_params)
    @site.users << current_user
    if @site.save
      @site.push_staged_changes
      @site.assign_sitelink_generator_names!
      Emailer.new_affiliate_site(@site, current_user).deliver_now
      SiteAutodiscoverer.new(@site).run
      redirect_to(
        site_path(@site),
        flash: {
          success:
              "You have added '#{@site.display_name}' as a site."
        }
      )
    else
      @site.site_domains.first.domain = "http://#{@site.site_domains.first.domain}" if @site.site_domains.first.domain.present?
      render(action: :new)
    end
  end

  def destroy
    @site.update_attributes!(active: false)
    @site.user_ids = []
    Resque.enqueue_with_priority(:low, SiteDestroyer, @site.id)
    redirect_to(
      new_site_path,
      flash: {
        success:
            "Scheduled site '#{@site.display_name}' for deletion. This could take several hours to complete."
      }
    )
  end

  def pin
    current_user.update_attributes!(default_affiliate: @site)
    redirect_back(
      fallback_location: root_path,
      flash: { success: "You have set #{@site.display_name} as your default site." }
    )
  end

  private

  def site_params
    @site_params ||= params.require(:site).
      permit(:display_name,
             :locale,
             :name,
             { site_domains_attributes: [:domain] }).to_h
  end
end
