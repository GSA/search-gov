class Affiliates::BoostedSitesController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :find_boosted_site, :only => [:edit, :update, :destroy]

  def new
    @title = "Boosted Sites - "
    @boosted_site = @affiliate.boosted_sites.new
  end

  def edit
    @title = "#{@boosted_site.title} - Edit Boosted Site"
  end

  def update
    if @boosted_site.update_attributes(params[:boosted_site])
      flash[:success] = "Boosted site successfully updated"
      redirect_to new_affiliate_boosted_site_path
    else
      flash[:error] = "There was a problem saving your boosted site"
      render :action => :edit
    end
  end

  def create
    @boosted_site = BoostedSite.create(params[:boosted_site].merge(:affiliate => @affiliate))
    if @boosted_site.errors.empty?
      flash[:success] = "Boosted site successfully added for affiliate '#{@affiliate.name}'"
      redirect_to new_affiliate_boosted_site_path
    else
      flash[:error] = "There was a problem saving your boosted site"
      render :action => :new
    end
  end

  def destroy
    @boosted_site.destroy
    flash[:success] = "Boosted site successfully deleted"
    redirect_to new_affiliate_boosted_site_path
  end

  def bulk
    if BoostedSite.process_boosted_site_xml_upload_for(@affiliate, params[:xml_file])
      flash[:success] = "Boosted sites uploaded successfully for affiliate '#{@affiliate.name}'"
      redirect_to new_affiliate_boosted_site_path
    else
      flash[:error] = "Your XML document could not be processed. Please check the format and try again."
      @boosted_site = @affiliate.boosted_sites.new
      render :action => 'new'
    end
  end

  private
  def find_boosted_site
    @boosted_site = BoostedSite.find(params[:id])
  end

end
