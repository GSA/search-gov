class Sites::TwitterProfilesController < Sites::SetupSiteController
  include Sites::ScaffoldProfilesController

  self.adapter_klass = TwitterData
  self.primary_attribute_name = :screen_name

  private

  def add_profile_to_site
    AffiliateTwitterSetting.create!(twitter_setting_params)
  end

  def human_profile_name
    "@#{@profile.screen_name}"
  end

  def twitter_setting_params
    { affiliate_id: @site.id,
      twitter_profile_id: @profile.id,
      show_lists: params[:show_lists] || 0 }
  end
end
