class Sites::TwitterProfilesController < Sites::BaseController
  include TextHelper

  before_filter :setup_site

  def index
    @twitter_profiles = @site.twitter_profiles
  end

  def new
    @twitter_profile = TwitterProfile.new
  end

  def create
    twitter_user = Twitter.user(twitter_profile_params[:screen_name]) rescue nil

    unless twitter_user
      @twitter_profile = TwitterProfile.new twitter_profile_params
      @twitter_profile.errors[:screen_name] = 'is not found'
      render action: :new and return
    end

    @twitter_profile = TwitterProfile.find_and_update_or_create! twitter_user
    if @site.twitter_profiles.exists?(@twitter_profile.id)
      @twitter_profile = TwitterProfile.new twitter_profile_params
      flash.now[:notice] = "You have already added @#{twitter_user.screen_name} to this site."
      render action: :new
    else
      twitter_setting = AffiliateTwitterSetting.new(twitter_setting_params)
      twitter_setting.save!

      @site.update_attributes!(is_twitter_govbox_enabled: true)

      redirect_to site_twitter_handles_path(@site),
                  flash: { success: "You have added @#{twitter_user.screen_name} to this site." }
    end
  end

  def destroy
    @twitter_profile = @site.twitter_profiles.find_by_id params[:id]
    redirect_to site_twitter_handles_path(@site) and return unless @twitter_profile

    @site.twitter_profiles.delete @twitter_profile
    redirect_to site_twitter_handles_path(@site),
                flash: { success: "You have removed @#{@twitter_profile.screen_name} from this site." }
  end

  private

  def twitter_profile_params
    @twitter_profile_params ||= params[:twitter_profile].slice(:screen_name)
  end

  def twitter_setting_params
    { affiliate_id: @site.id,
      twitter_profile_id: @twitter_profile.id,
      show_lists: params[:show_lists] || 0 }
  end
end
