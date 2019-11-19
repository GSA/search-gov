class Sites::YoutubeProfilesController < Sites::SetupSiteController
  include Sites::ScaffoldProfilesController

  self.adapter_klass = YoutubeProfileData
  self.primary_attribute_name = :url

  private

  def add_profile_to_site
    super
    @site.enable_video_govbox!
  end

  def after_profile_deleted
    @site.disable_video_govbox! unless @site.youtube_profiles.reload.exists?
  end

  def human_profile_name
    "#{@profile.title} channel"
  end
end
