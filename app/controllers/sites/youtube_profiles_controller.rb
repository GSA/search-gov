class Sites::YoutubeProfilesController < Sites::SetupSiteController
  include Sites::ScaffoldProfilesController

  self.adapter_klass = YoutubeData
  self.primary_attribute_name = :username

  private

  def add_profile_to_site
    super
    @site.enable_video_govbox!
  end

  def after_profile_deleted
    @site.disable_video_govbox! unless @site.youtube_profiles(true).exists?
  end
end
