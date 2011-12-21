class Affiliates::SitemapsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def index
    @title = 'Sitemaps - '
    @sitemaps = @affiliate.sitemaps.paginate(:all, :per_page => 10, :page => params[:page])
  end

  def new
    @title = 'Add a new Sitemap - '
    @sitemap = @affiliate.sitemaps.build
  end

  def create
    @sitemap = @affiliate.sitemaps.build(params[:sitemap])
    if @sitemap.save
      redirect_to affiliate_sitemaps_path(@affiliate), :flash => { :success => 'Sitemap successfully added.' }
    else
      @title = 'Add a new Sitemap - '
      render :action => :new
    end
  end

  def destroy
    @sitemap = Sitemap.find_by_id(params[:id])
    @sitemap.destroy if @sitemap
    redirect_to affiliate_sitemaps_path(@affiliate), :flash => { :success => 'Sitemap successfully deleted.' }
  end
end