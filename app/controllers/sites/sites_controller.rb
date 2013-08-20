class Sites::SitesController < Sites::BaseController
  before_filter :setup_site, :except => [:new, :create]

  def show
    @dashboard = Dashboard.new(@site)
  end

  def new
    @site = Affiliate.new
  end

  def create
    @site = Affiliate.new(params[:affiliate].except(:name))
    @site.name = params[:affiliate][:name]
    @site.users << current_user
    if @site.save
      @site.push_staged_changes
      Emailer.new_affiliate_site(@site, current_user).deliver
      redirect_to site_path(@site), flash: {success: "You have added '#{@site.display_name}' as a site."}
    else
      render :action => :new
    end
  end
end
