class Sites::YoutubeProfilesController < Sites::BaseController
  before_filter :setup_site

  def index
    @youtube_profiles = @site.youtube_profiles
  end

  def new
    @youtube_profile = YoutubeProfile.new
  end

  def create
    @youtube_profile = YoutubeProfile.where(youtube_profile_params).first_or_initialize
    if !@youtube_profile.new_record? || @youtube_profile.save
      if @site.youtube_profiles.exists?(@youtube_profile.id)
        @youtube_profile = YoutubeProfile.new youtube_profile_params
        flash.now[:notice] = "You have already added #{@youtube_profile.username} to this site."
        render action: :new
      else
        @site.youtube_profiles << @youtube_profile
        RssFeed.enable_youtube_govbox! @site
        redirect_to site_youtube_usernames_path(@site),
                    flash: { success: "You have added #{@youtube_profile.username} to this site." }
      end
    else
      render action: :new
    end
  end

  def destroy
    @youtube_profile = @site.youtube_profiles.find_by_id params[:id]
    redirect_to site_youtube_usernames_path(@site) and return unless @youtube_profile

    @site.youtube_profiles.delete @youtube_profile
    redirect_to site_youtube_usernames_path(@site),
                flash: { success: "You have removed #{@youtube_profile.username} from this site." }
  end

  private

  def youtube_profile_params
    @youtube_profile_params ||= begin
      hash = params[:youtube_profile].slice(:username)
      Hash[hash.map { |key, value| [key, value.present? ? value.strip : value] }]
    end
  end
end
