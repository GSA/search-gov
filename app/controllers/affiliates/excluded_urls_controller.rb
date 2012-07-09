class Affiliates::ExcludedUrlsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def index
    @title = 'Emergecy Delete - '
    @excluded_urls = @affiliate.excluded_urls.paginate(:all, :per_page => 10, :page => params[:page])
    @excluded_url = @affiliate.excluded_urls.build
  end

  def create
    @excluded_url = @affiliate.excluded_urls.build(params[:excluded_url])
    if @excluded_url.save
      redirect_to affiliate_excluded_urls_path(@affiliate), :flash => { :success => 'Emergency Delete Url successfully created.' }
    else
      @excluded_urls = @affiliate.excluded_urls.paginate(:all, :per_page => 10, :page => params[:page])
      render :action => :index
    end
  end

  def destroy
    @excluded_url = ExcludedUrl.find(params[:id])
    @excluded_url.destroy
    redirect_to affiliate_excluded_urls_path(@affiliate), :flash => { :success => 'Emergency Delete URL successfully deleted.' }
  end
end