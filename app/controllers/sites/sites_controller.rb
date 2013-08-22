class Sites::SitesController < Sites::BaseController
  before_filter :setup_site, only: [:show, :pin]

  def index
    if current_user.is_affiliate_admin? and current_user.default_affiliate
      redirect_to site_path(current_user.default_affiliate)
    elsif current_user.is_affiliate? &&
        current_user.affiliates.exists?(current_user.default_affiliate_id)
      redirect_to site_path(current_user.default_affiliate)
    elsif current_user.affiliates.first
      redirect_to site_path(current_user.affiliates.first)
    else
      redirect_to new_site_path
    end
  end

  def show
    @dashboard = Dashboard.new(@site)
  end

  def new
    @site = Affiliate.new
    @site.site_domains.build
  end

  def create
    @site = Affiliate.new(params[:affiliate].except(:name))
    @site.name = params[:affiliate][:name]
    @site.users << current_user
    if @site.save
      @site.push_staged_changes
      Emailer.new_affiliate_site(@site, current_user).deliver
      redirect_to site_path(@site), flash: { success: "You have added '#{@site.display_name}' as a site." }
    else
      @site.site_domains.first.domain = "http://#{@site.site_domains.first.domain}" if @site.site_domains.first.domain.present?
      render action: :new
    end
  end

  def pin
    current_user.update_attributes! default_affiliate: @site
    redirect_to :back, flash: { success: "You have set #{@site.display_name} as your default site." }
  end
end
