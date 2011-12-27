class Affiliates::SiteDomainsController < Affiliates::AffiliatesController
  include ActionView::Helpers::TextHelper

  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :setup_site_domain, :only => [:edit, :update, :destroy]

  def index
    @site_domains = @affiliate.site_domains.paginate(:all,
                                                     :per_page => SiteDomain.per_page,
                                                     :page => params[:page],
                                                     :order => 'updated_at DESC, id DESC')
  end

  def new
    @site_domain = @affiliate.site_domains.build
  end

  def create
    @site_domain = @affiliate.site_domains.build(params[:site_domain])
    if @site_domain.save
      redirect_to affiliate_site_domains_path(@affiliate), :flash => { :success => "Domain was successfully added." }
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @affiliate.update_site_domain(@site_domain, params[:site_domain])
      redirect_to affiliate_site_domains_path(@affiliate), :flash => { :success => "Domain was successfully updated." }
    else
      render :action => :edit
    end
  end

  def destroy
    @site_domain.destroy
    redirect_to affiliate_site_domains_path(@affiliate), :flash => { :success => "Domain was successfully deleted." }
  end

  def bulk_new
  end

  def upload
    result = SiteDomain.process_file(@affiliate, params[:site_domains])
    if result[:success]
      redirect_to affiliate_site_domains_path(@affiliate),
                  :flash => { :success => "Successfully uploaded #{pluralize(result[:added], 'domain')}." }
    else
      flash.now[:error] = result[:error_message]
      render :action => :bulk_new
    end
  end

  private
  def setup_site_domain
    @site_domain = @affiliate.site_domains.find_by_id(params[:id])
    redirect_to affiliate_site_domains_path(@affiliate) unless @site_domain
  end
end

