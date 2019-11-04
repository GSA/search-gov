class Sites::FlickrProfilesController < Sites::SetupSiteController
  def index
    @flickr_profiles = @site.flickr_profiles
  end

  def new
    @flickr_profile = @site.flickr_profiles.build
  end

  def create
    @flickr_profile = @site.flickr_profiles.build flickr_profile_params
    if @flickr_profile.save
      redirect_to site_flickr_urls_path(@site),
                  flash: { success: "You have added #{UrlParser.strip_http_protocols(@flickr_profile.url)} to this site." }
    else
      render action: :new
    end
  end

  def destroy
    @flickr_profile = @site.flickr_profiles.find_by_id params[:id]
    redirect_to site_flickr_urls_path(@site) and return unless @flickr_profile

    @flickr_profile.destroy
    redirect_to site_flickr_urls_path(@site),
                flash: { success: "You have removed #{UrlParser.strip_http_protocols(@flickr_profile.url)} from this site." }
  end

  private

  def flickr_profile_params
    @flickr_profile_params ||= params.require(:flickr_profile).permit(:url).to_h
  end
end
