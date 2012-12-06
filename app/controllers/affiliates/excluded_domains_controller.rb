class Affiliates::ExcludedDomainsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def index
    @title = 'Excluded Domains - '
    @excluded_domains = @affiliate.excluded_domains.to_a
    @excluded_domain = @affiliate.excluded_domains.build
  end

  def create
    @excluded_domains = @affiliate.excluded_domains.to_a
    @excluded_domain = @affiliate.excluded_domains.build(params[:excluded_domain])
    if @excluded_domain.save
      redirect_to affiliate_excluded_domains_path(@affiliate), :flash => { :success => 'Excluded domain successfully created.' }
    else
      render :action => :index
    end
  end

  def destroy
    @excluded_domain = ExcludedDomain.find(params[:id])
    @excluded_domain.destroy
    redirect_to affiliate_excluded_domains_path(@affiliate), :flash => { :success => 'Excluded domain successfully deleted.' }
  end
end