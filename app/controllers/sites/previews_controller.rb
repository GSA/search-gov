class Sites::PreviewsController < Sites::SetupSiteController

  def show
    respond_to do |format|
      format.html { render layout: false }
    end
  end
end
