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

    context 'when adding an existing Twitter Profile' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:profile) { TwitterProfile.create!(:screen_name => 'USASearch') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        TwitterProfile.should_receive(:find_or_initialize_by_screen_name).and_return(profile)
        twitter_profiles = mock('twitter profiles')
        affiliate.stub(:twitter_profiles).and_return(twitter_profiles)
        twitter_profiles.should_receive(:exists?).with(profile).and_return(false)
        twitter_profiles.should_receive(:<<).with(profile)

        put :create,
            :affiliate_id => affiliate.id,
            :profile_type => 'TwitterProfile',
            :social_media_profile => { :screen_name => 'USASearch' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:profile).with(profile) }
      it { should set_the_flash.to(/added/i) }
      it { should redirect_to(affiliate_social_media_path(affiliate)) }
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
        profile = TwitterProfile.create!(:screen_name => 'USASearch')
        affiliate.twitter_profiles << profile
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        TwitterProfile.should_receive(:find).with(profile.id.to_s).and_return(profile)
        twitter_profiles = mock('twitter profiles')
        affiliate.should_receive(:twitter_profiles).and_return(twitter_profiles)
        twitter_profiles.should_receive(:delete).with(profile)

        delete :destroy,
               :affiliate_id => affiliate.id,
               :profile_type => 'TwitterProfile',
               :id => profile.id.to_s
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to('Twitter Profile successfully deleted') }
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
