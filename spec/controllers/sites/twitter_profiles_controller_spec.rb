require 'spec_helper'

describe Sites::TwitterProfilesController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:twitter_profiles) { mock('twitter profiles') }

      before do
        site.should_receive(:twitter_profiles).and_return(twitter_profiles)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:twitter_profiles).with(twitter_profiles) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when screen name is valid and it has not been added to the site' do
        let(:twitter_user) { mock('Twitter User', screen_name: 'USASearch') }
        let(:twitter_profile) { mock_model(TwitterProfile) }
        let(:twitter_setting) { mock_model(AffiliateTwitterSetting) }

        before do
          Twitter.should_receive(:user).with('usasearch').and_return(twitter_user)
          TwitterProfile.should_receive(:find_and_update_or_create!).
              with(twitter_user).
              and_return(twitter_profile)

          twitter_profiles = mock('twitter profiles')
          site.stub(:twitter_profiles).and_return(twitter_profiles)
          twitter_profiles.should_receive(:exists?).
              with(twitter_profile.id).
              and_return(false)

          AffiliateTwitterSetting.should_receive(:new).
              with(affiliate_id: site.id,
                   twitter_profile_id: twitter_profile.id,
                   show_lists: '1').
              and_return(twitter_setting)
          twitter_setting.should_receive(:save!)

          post :create,
               site_id: site.id,
               twitter_profile: { screen_name: 'usasearch', not_allowed_key: 'not allowed value' },
               show_lists: 1
        end

        it { should redirect_to(site_twitter_handles_path(site)) }
        it { should set_the_flash.to(/You have added @USASearch to this site/) }
      end

      context 'when screen name is valid and it has already been added to the site' do
        let(:twitter_user) { mock('Twitter User', screen_name: 'USASearch') }
        let(:existing_twitter_profile) { mock_model(TwitterProfile) }
        let(:new_twitter_profile) { mock_model(TwitterProfile, id: nil, new_record?: true) }

        before do
          Twitter.should_receive(:user).with('usasearch').and_return(twitter_user)
          TwitterProfile.should_receive(:find_and_update_or_create!).
              with(twitter_user).
              and_return(existing_twitter_profile)

          twitter_profiles = mock('twitter profiles')
          site.stub(:twitter_profiles).and_return(twitter_profiles)
          twitter_profiles.should_receive(:exists?).
              with(existing_twitter_profile.id).
              and_return(true)

          TwitterProfile.should_receive(:new).
              with('screen_name' => 'usasearch').
              and_return(new_twitter_profile)

          post :create,
               site_id: site.id,
               twitter_profile: { screen_name: 'usasearch', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:twitter_profile).with(new_twitter_profile) }
        it { should set_the_flash[:notice].to(/You have already added @USASearch to this site/).now }
        it { should render_template(:new) }
      end

      context 'when screen name is not valid' do
        let(:new_twitter_profile) { mock_model(TwitterProfile, id: nil, new_record?: true) }

        before do
          Twitter.should_receive(:user).with('invalid handle').and_return(nil)
          TwitterProfile.should_receive(:new).
              with('screen_name' => 'invalid handle').
              and_return(new_twitter_profile)

          post :create,
               site_id: site.id,
               twitter_profile: { screen_name: 'invalid handle', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:twitter_profile).with(new_twitter_profile) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        twitter_profiles = mock('twitter profiles')
        site.stub(:twitter_profiles).and_return(twitter_profiles)

        twitter_profile = mock_model(TwitterProfile, screen_name: 'USASearch')
        twitter_profiles.should_receive(:find_by_id).with('100').
            and_return(twitter_profile)
        twitter_profiles.should_receive(:delete).with(twitter_profile)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_twitter_handles_path(site)) }
      it { should set_the_flash.to(/You have removed @USASearch from this site/) }
    end
  end
end
