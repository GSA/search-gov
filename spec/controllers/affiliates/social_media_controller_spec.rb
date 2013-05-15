require 'spec_helper'

describe Affiliates::SocialMediaController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    context 'when not logged in' do
      before do
        get :index, :affiliate_id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context 'when logged in as an affiliate manager who does not own the affiliate' do
      before do
        UserSession.create(users(:affiliate_manager))
        get :index, :affiliate_id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context 'when logged in as the affiliate manager' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }
    end

    context 'when profile_type is set to invalid value' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        get :index, :affiliate_id => affiliate.id, :profile_type => 'invalid'
      end

      it { should_not assign_to(:profile) }
      it { should respond_with(:success) }
    end
  end

  describe '#create' do
    context 'when not logged in' do
      before do
        post :create,
             :affiliate_id => affiliates(:power_affiliate).id,
             :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
             :social_media_profile => { :username => 'fb' }
      end

      it { should redirect_to login_path }
    end

    context 'when logged in as an affiliate manager who does not own the affiliate' do
      before do
        UserSession.create(users(:affiliate_manager))
        post :create,
             :affiliate_id => affiliates(:another_affiliate).id,
             :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
             :social_media_profile => { :username => 'fb' }
      end

      it { should redirect_to home_page_path }
    end

    context 'when successfully add a social media profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        put :create,
            :affiliate_id => affiliate.id,
            :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
            :social_media_profile => { :username => 'fb' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/added/i) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end

    context 'when failed add a social media profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        facebook_profiles = mock('facebook profiles')
        affiliate.should_receive(:facebook_profiles).and_return(facebook_profiles)
        profile = mock_model(FacebookProfile, :new_record? => true)
        facebook_profiles.should_receive(:build).with('username' => 'fb').and_return(profile)
        profile.should_receive(:save).and_return(false)

        put :create,
            :affiliate_id => affiliate.id,
            :profile_type => 'FacebookProfile',
            :social_media_profile => { :username => 'fb' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should render_template(:index) }
      it { should respond_with(:success) }
    end

    context 'when adding Flickr profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:profile) { mock_model(FlickrProfile, :new_record? => true) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        flickr_profiles = mock('flickr profiles')
        affiliate.should_receive(:flickr_profiles).and_return(flickr_profiles)
        flickr_profiles.should_receive(:build).with('url' => 'http://flickr_url').and_return(profile)
        profile.should_receive(:save).and_return(true)
        affiliate.should_receive(:update_attributes!).with(:is_photo_govbox_enabled => true)

        put :create,
            :affiliate_id => affiliate.id,
            :profile_type => 'FlickrProfile',
            :social_media_profile => { :url => 'http://flickr_url' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:profile).with(profile) }
      it { should set_the_flash.to(/added/i) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end

    context 'when adding an existing Twitter Profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:profile) { mock_model(TwitterProfile, new_record?: false) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        controller.should_receive(:find_or_initialize_profile).and_return(profile)
        twitter_profiles = mock('twitter profiles')
        affiliate.stub(:twitter_profiles).and_return(twitter_profiles)
        twitter_profiles.should_receive(:exists?).with(profile).and_return true
        twitter_profiles.should_not_receive(:<<)

        twitter_setting = mock_model(AffiliateTwitterSetting)
        affiliate.stub_chain(:affiliate_twitter_settings, :find_by_twitter_profile_id).and_return(twitter_setting)
        twitter_setting.should_receive(:update_attributes!).with(show_lists: '1')
        affiliate.should_receive(:update_attributes!).with(is_twitter_govbox_enabled: true)

        put :create,
            :affiliate_id => affiliate.id.to_s,
            :profile_type => 'TwitterProfile',
            :show_lists => '1',
            :social_media_profile => { :screen_name => 'USASearch' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:profile).with(profile) }
      it { should set_the_flash.to(/added/i) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end

    context 'when profile_type is YoutubeProfile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:profile) { mock_model(YoutubeProfile) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        controller.should_receive(:find_or_initialize_profile).and_return(profile)

        rss_feed = mock_model(RssFeed)
        affiliate.stub_chain(:rss_feeds, :where, :first_or_initialize).and_return rss_feed
        rss_feed.should_receive(:shown_in_govbox=).with true
        rss_feed.should_receive :save!
      end

      context 'when the profile is a new record' do
        before do
          profile.should_receive(:new_record?).and_return true
          profile.should_receive(:save).and_return true
          youtube_profiles = mock('youtube profiles')
          affiliate.stub(:youtube_profiles).and_return(youtube_profiles)
          affiliate.stub_chain(:youtube_profiles, :exists?).and_return false
          affiliate.youtube_profiles.should_receive(:<<).with(profile)

          put :create,
              :affiliate_id => affiliate.id,
              :profile_type => 'YoutubeProfile',
              :social_media_profile => { :username => 'USASearch' }
        end

        it { should assign_to(:affiliate).with(affiliate) }
        it { should assign_to(:profile).with(profile) }
        it { should set_the_flash.to(/added/i) }
        it { should redirect_to(affiliate_social_media_path(affiliate)) }
      end

      context 'when the profile is not a new record' do
        before do
          profile.should_receive(:new_record?).and_return false
          profile.should_not_receive :save
          youtube_profiles = mock('youtube profiles')
          affiliate.stub(:youtube_profiles).and_return(youtube_profiles)
          affiliate.stub_chain(:youtube_profiles, :exists?).and_return true
          affiliate.youtube_profiles.should_not_receive(:<<)

          put :create,
              :affiliate_id => affiliate.id,
              :profile_type => 'YoutubeProfile',
              :social_media_profile => { :username => 'USASearch' }
        end

        it { should assign_to(:affiliate).with(affiliate) }
        it { should assign_to(:profile).with(profile) }
        it { should set_the_flash.to(/added/i) }
        it { should redirect_to(affiliate_social_media_path(affiliate)) }
      end
    end
  end

  describe '#destroy' do
    context 'when not logged in' do
      before do
        affiliate = affiliates(:power_affiliate)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        delete :destroy,
               :affiliate_id => affiliate.id,
               :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
               :id => profile.id
      end

      it { should redirect_to login_path }
    end

    context 'when logged in as an affiliate manager who does not own the affiliate' do
      before do
        affiliate = affiliates(:another_affiliate)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')

        UserSession.create(users(:affiliate_manager))
        delete :destroy,
               :affiliate_id => affiliate.id,
               :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
               :id => profile.id
      end

      it { should redirect_to home_page_path }
    end

    context 'when logged in as an affiliate manager' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:facebook_profiles, :find).with(profile.id.to_s).and_return(profile)
        profile.should_receive(:destroy)

        delete :destroy,
               :affiliate_id => affiliate.id,
               :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
               :id => profile.id.to_s
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end

    context 'when deleting twitter profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        profile = mock_model(TwitterProfile)
        TwitterProfile.should_receive(:find).with(profile.id.to_s).and_return(profile)
        twitter_profiles = mock('twitter profiles')
        affiliate.should_receive(:twitter_profiles).and_return(twitter_profiles)
        twitter_profiles.should_receive(:delete).with(profile)

        delete :destroy,
               :affiliate_id => affiliate.id.to_s,
               :profile_type => 'TwitterProfile',
               :id => profile.id.to_s
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to('Twitter Profile successfully deleted') }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end

    context 'when deleting YoutubeProfile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        profile = mock_model(YoutubeProfile)
        YoutubeProfile.should_receive(:find).with(profile.id.to_s).and_return(profile)
        youtube_profiles = mock('youtube profiles')
        affiliate.should_receive(:youtube_profiles).and_return(youtube_profiles)
        youtube_profiles.should_receive(:delete).with(profile)

        delete :destroy,
               :affiliate_id => affiliate.id.to_s,
               :profile_type => 'YoutubeProfile',
               :id => profile.id.to_s
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to('Youtube Profile successfully deleted') }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end
  end

  describe '#preview' do
    context 'when not logged in' do
      before do
        affiliate = affiliates(:power_affiliate)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        get :preview,
            :affiliate_id => affiliate.id,
            :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
            :id => profile.id
      end

      it { should redirect_to login_path }
    end

    context 'when logged in as an affiliate manager who does not own the affiliate' do
      before do
        affiliate = affiliates(:another_affiliate)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        UserSession.create(users(:affiliate_manager))
        get :preview,
            :affiliate_id => affiliate.id,
            :profile_type => Affiliates::SocialMediaController::PROFILE_TYPES.first,
            :id => profile.id
      end

      it { should redirect_to home_page_path }
    end

    context 'when logged in as the affiliate manager' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:recent_tweets) { mock('recent tweets') }

      before do
        Twitter.stub!(:user).and_return mock('Twitter', :id => 123, :name => 'USASearch', :profile_image_url => 'http://some.gov/url')
        profile = affiliate.twitter_profiles.create!(:screen_name => 'USASearch')
        profile.should_receive(:recent).and_return(recent_tweets)
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        affiliate.stub_chain(:twitter_profiles, :find).with(profile.id.to_s).and_return(profile)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        get :preview,
            :affiliate_id => affiliate.id,
            :profile_type => 'TwitterProfile',
            :id => profile.id.to_s
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:recent_social_media).with(recent_tweets)}
      it { should respond_with(:success) }
    end

    context 'when profile_type is set to invalid value' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        get :preview,
            :affiliate_id => affiliate.id,
            :profile_type => 'invalid',
            :id => profile.id
      end

      it { should_not assign_to(:profile) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end
  end

  describe '#new_profile_fields' do
    Affiliates::SocialMediaController::PROFILE_TYPES.each do |profile_type|
      context "when profile_type is set to #{profile_type}" do
        let(:affiliate) { affiliates(:basic_affiliate) }
        let(:current_user) { users(:affiliate_manager) }

        before do
          UserSession.create(current_user)
          get :new_profile_fields,
              :affiliate_id => affiliate.id,
              :profile_type => profile_type,
              :format => :js
        end

        it { should render_template("new_#{profile_type.underscore}_fields") }
      end
    end

    context 'when profile_type is set to invalid value' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        profile = affiliate.facebook_profiles.create!(:username => 'fb')
        get :preview,
            :affiliate_id => affiliate.id,
            :profile_type => 'invalid',
            :id => profile.id
      end

      it { should_not assign_to(:profile) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
    end
  end
end
