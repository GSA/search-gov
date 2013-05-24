class Affiliates::SocialMediaController < Affiliates::AffiliatesController
  PROFILE_TYPES = %w(FacebookProfile FlickrProfile TwitterProfile YoutubeProfile).freeze
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate, :except => [:new_profile_fields]
  before_filter :validate_profile_type, :except => [:index]

  def index
    if params[:profile_type].present? and PROFILE_TYPES.include?(params[:profile_type])
      @profile = Object::const_get(params[:profile_type]).new
    end
  end

  def create
    @profile = find_or_initialize_profile
    if @profile.new_record?
      render(action: :index) && return unless @profile.save
    end

    case @profile
    when FlickrProfile
      @affiliate.update_attributes!(is_photo_govbox_enabled: true)
    when TwitterProfile
      @affiliate.twitter_profiles << @profile unless @affiliate.twitter_profiles.exists? @profile
      show_lists = params[:show_lists] || 0
      @affiliate.affiliate_twitter_settings.find_by_twitter_profile_id(@profile.id).update_attributes!(show_lists: show_lists)
      @affiliate.update_attributes!(is_twitter_govbox_enabled: true)
    when YoutubeProfile
      @affiliate.youtube_profiles << @profile unless @affiliate.youtube_profiles.exists? @profile
      rss_feed = @affiliate.rss_feeds.where(is_managed: true).first_or_initialize(name: 'Videos')
      rss_feed.shown_in_govbox = true
      rss_feed.save!
    end

    flash[:success] = "Added #{@profile.class.name.titleize}"
    redirect_to affiliate_social_media_path(@affiliate)
  end

  def destroy
    if %w(YoutubeProfile TwitterProfile).include? params[:profile_type]
      profile = profile_type_class.send(:find, params[:id])
      @affiliate.send(profile.class.name.tableize).send(:delete, profile)
      if params[:profile_type] == 'YoutubeProfile' and @affiliate.youtube_profiles.empty?
        @affiliate.rss_feeds.managed.destroy_all
      end
    else
      profile = @affiliate.send(params[:profile_type].tableize).find(params[:id]).destroy
    end
    flash[:success] = "#{profile.class.name.titleize} successfully deleted"
    redirect_to affiliate_social_media_path(@affiliate)
  end

  def preview
    @recent_social_media = @affiliate.
        send(:"#{params[:profile_type].underscore}s").
        find(params[:id]).
        recent
    @page_title = case params[:profile_type]
                  when 'FlickrProfile' then 'Recent Flickr photos'
                  when 'TwitterProfile' then 'Recent tweets'
                  when 'YoutubeProfile' then 'Recent YouTube videos'
                  end
  end

  def new_profile_fields
    request.format = :js
    render "new_#{params[:profile_type].underscore}_fields"
  end

  def validate_profile_type
    redirect_to affiliate_social_media_path(@affiliate) unless PROFILE_TYPES.include?(params[:profile_type])
  end

  def find_or_initialize_profile
    case params[:profile_type]
    when TwitterProfile.name
      TwitterProfile.where(screen_name: params[:social_media_profile][:screen_name]).first_or_initialize
    when YoutubeProfile.name
      YoutubeProfile.where(username: params[:social_media_profile][:username]).first_or_initialize
    else
      @affiliate.send(params[:profile_type].tableize).build(params[:social_media_profile])
    end
  end

  def profile_type_class
    @profile_type_class ||= Module.const_get params[:profile_type].to_sym
  end
end
