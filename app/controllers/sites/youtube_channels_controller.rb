class Sites::YoutubeChannelsController < Sites::BaseController
  before_filter :setup_site

  def index
    @youtube_channels = @site.youtube_profiles
  end

  def new
    @youtube_channel = YoutubeProfile.new
  end

  def create
    @youtube_channel = YoutubeProfile.where(youtube_channel_params).first_or_initialize
    if !@youtube_channel.new_record? || @youtube_channel.save
      if @site.youtube_profiles.exists?(@youtube_channel.id)
        @youtube_channel = YoutubeProfile.new youtube_channel_params
        flash.now[:notice] = "You have already added #{@youtube_channel.username} channel to this site."
        render action: :new
      else
        @site.youtube_profiles << @youtube_channel
        RssFeed.enable_youtube_govbox! @site
        redirect_to site_youtube_channels_path(@site),
                    flash: { success: "You have added #{@youtube_channel.username} channel to this site." }
      end
    else
      render action: :new
    end
  end

  def destroy
    @youtube_channel = @site.youtube_profiles.find_by_id params[:id]
    redirect_to site_youtube_channels_path(@site) and return unless @youtube_channel

    @site.youtube_profiles.delete @youtube_channel
    redirect_to site_youtube_channels_path(@site),
                flash: { success: "You have removed #{@youtube_channel.username} channel from this site." }
  end

  private

  def youtube_channel_params
    @youtube_channel_params ||= params[:youtube_channel].slice(:username)
  end
end
