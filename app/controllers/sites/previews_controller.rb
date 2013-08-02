class Sites::PreviewsController < Sites::BaseController
  before_filter :setup_site

  def show
    respond_to do |format|
      format.html { render layout: false }
    end
  end
end
