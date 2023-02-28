require 'spec_helper'

describe Sites::TwitterProfilesController do
  fixtures :users, :affiliates, :memberships
  let(:client) { double('TwitterClient') }

  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:twitter_profiles) { double('twitter profiles') }

      before do
        expect(site).to receive(:twitter_profiles).and_return(twitter_profiles)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:profiles).with(twitter_profiles) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when screen name is valid and it has not been added to the site' do
        let(:twitter_user) { double('Twitter User', screen_name: 'USASearch') }
        let(:twitter_profile) { mock_model(TwitterProfile, screen_name: 'USASearch') }
        let(:twitter_setting) { mock_model(AffiliateTwitterSetting) }

        before do
          expect(TwitterData).to receive(:import_profile).
            with('usasearch').
            and_return(twitter_profile)

          twitter_profiles = double('twitter profiles')
          allow(site).to receive(:twitter_profiles).and_return(twitter_profiles)
          expect(twitter_profiles).to receive(:exists?).
            with(twitter_profile.id).
            and_return(false)

          expect(AffiliateTwitterSetting).to receive(:create!).
            with({ affiliate_id: site.id,
                   twitter_profile_id: twitter_profile.id,
                   show_lists: '1' })

          post :create,
               params: {
                 site_id: site.id,
                 twitter_profile: {
                   screen_name: 'usasearch',
                   not_allowed_key: 'not allowed value'
                 },
                 show_lists: 1
               }
        end

        it { is_expected.to redirect_to(site_twitter_handles_path(site)) }
        it { is_expected.to set_flash.to(/You have added @USASearch to this site/) }
      end

      context 'when screen name is valid and it has already been added to the site' do
        let(:twitter_user) { double('Twitter User', screen_name: 'USASearch') }
        let(:existing_twitter_profile) { mock_model(TwitterProfile) }
        let(:new_twitter_profile) { mock_model(TwitterProfile, id: nil, screen_name: 'USASearch', new_record?: true) }

        before do
          expect(TwitterData).to receive(:import_profile).
            with('usasearch').
            and_return(existing_twitter_profile)

          twitter_profiles = double('twitter profiles')
          allow(site).to receive(:twitter_profiles).and_return(twitter_profiles)
          expect(twitter_profiles).to receive(:exists?).
            with(existing_twitter_profile.id).
            and_return(true)

          expect(TwitterProfile).to receive(:new).
            with({ 'screen_name' => 'usasearch' }).
            and_return(new_twitter_profile)

          post :create,
               params: {
                 site_id: site.id,
                 twitter_profile: {
                   screen_name: 'usasearch',
                   not_allowed_key: 'not allowed value'
                 }
               }
        end

        it { is_expected.to assign_to(:profile).with(new_twitter_profile) }
        it { is_expected.to set_flash.now[:notice].to(/You have already added @USASearch to this site/) }
        it { is_expected.to render_template(:new) }
      end

      context 'when screen name is not valid' do
        let(:new_twitter_profile) { mock_model(TwitterProfile, id: nil, new_record?: true) }

        before do
          expect(TwitterData).to receive(:import_profile).with('invalid handle').and_return(nil)
          expect(TwitterProfile).to receive(:new).
            with({ 'screen_name' => 'invalid handle' }).
            and_return(new_twitter_profile)

          post :create,
               params: {
                 site_id: site.id,
                 twitter_profile: { screen_name: 'invalid handle',
                                    not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:profile).with(new_twitter_profile) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        twitter_profiles = double('twitter profiles')
        allow(site).to receive(:twitter_profiles).and_return(twitter_profiles)

        twitter_profile = mock_model(TwitterProfile, screen_name: 'USASearch')
        expect(twitter_profiles).to receive(:find_by_id).with('100').
          and_return(twitter_profile)
        expect(twitter_profiles).to receive(:delete).with(twitter_profile)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_twitter_handles_path(site)) }
      it { is_expected.to set_flash.to(/You have removed @USASearch from this site/) }
    end
  end
end
