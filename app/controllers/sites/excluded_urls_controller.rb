class Sites::ExcludedUrlsController < Sites::SetupSiteController
  before_action :setup_site
  before_action :setup_excluded_url, only: [:destroy]

  def index
    @excluded_urls = @site.excluded_urls.paginate(
        page: params[:page]).order('url ASC')
  end

  def new
    @excluded_url = @site.excluded_urls.build
  end

  def create
    @excluded_url = @site.excluded_urls.build excluded_url_params
    if @excluded_url.save
      redirect_to site_filter_urls_path(@site),
                  flash: { success: "You have added #{UrlParser.strip_http_protocols(@excluded_url.url)} to this site." }
    else
      render action: :new
    end
  end

  def destroy
    @excluded_url.destroy
    redirect_to site_filter_urls_path(@site),
                flash: { success: "You have removed #{UrlParser.strip_http_protocols(@excluded_url.url)} from this site." }
  end

  private

  def setup_excluded_url
    @excluded_url = @site.excluded_urls.find_by_id params[:id]
    redirect_to site_filter_urls_path(@site) unless @excluded_url
  end

  def excluded_url_params
    params.require(:excluded_url).permit(:url).to_h
  end
end
