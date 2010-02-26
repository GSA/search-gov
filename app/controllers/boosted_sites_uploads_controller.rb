class BoostedSitesUploadsController < AffiliateAuthController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def new
  end

  def create
    if BoostedSite.process_boosted_site_xml_upload_for(@affiliate, params[:xmlfile])
      flash[:success] = "Boosted sites uploaded successfully for affiliate '#{@affiliate.name}'"
      redirect_to account_path
    else
      flash[:error] = "Your XML document could not be processed. Please check the format and try again."
      render :action => 'new'
    end
  end

end
