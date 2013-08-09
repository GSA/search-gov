class Sites::FlickrUrlsController < Sites::BaseController
  include TextHelper

  before_filter :setup_site

  def index
    @flickr_urls = @site.flickr_profiles
  end

  def new
    @flickr_url = @site.flickr_profiles.build
  end

  def create
    @flickr_url = @site.flickr_profiles.build flickr_url_params
    if @flickr_url.save
      @site.update_attributes!(is_photo_govbox_enabled: true)
      redirect_to site_flickr_urls_path(@site),
                  flash: { success: "You have added #{url_without_protocol(@flickr_url.url)} to this site." }
    else
      render action: :new
    end
  end

  def destroy
    @flickr_url = @site.flickr_profiles.find_by_id params[:id]
    redirect_to site_flickr_urls_path(@site) and return unless @flickr_url

    @flickr_url.destroy
    redirect_to site_flickr_urls_path(@site),
                flash: { success: "You have removed #{url_without_protocol(@flickr_url.url)} from this site." }
  end

  private

  def flickr_url_params
    @flickr_url_params ||= params[:flickr_url].slice(:url)
  end
end
