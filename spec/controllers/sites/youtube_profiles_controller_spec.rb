require 'spec_helper'

describe Sites::YoutubeProfilesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:youtube_profiles) { double('youtube profiles') }

      before do
        expect(site).to receive(:youtube_profiles).and_return(youtube_profiles)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:profiles).with(youtube_profiles) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when channel URL is valid and it has not been added to the site' do
        let(:youtube_profile) do
          mock_model(YoutubeProfile,
                     channel_id: 'us_government_channel_id',
                     title: 'USGovernment')
        end

        before do
          expect(YoutubeProfileData).to receive(:import_profile).
            with('youtube.com/channel/us_government_channel_id').and_return(youtube_profile)
          youtube_profiles = double('youtube profiles')
          allow(site).to receive(:youtube_profiles).and_return(youtube_profiles)
          expect(youtube_profiles).to receive(:exists?).
            with(youtube_profile.id).
            and_return(false)
          expect(youtube_profiles).to receive(:<<).with(youtube_profile)
          expect(site).to receive(:enable_video_govbox!)

          post :create,
               params: {
                 site_id: site.id,
                 youtube_profile: {
                   url: 'youtube.com/channel/us_government_channel_id',
                   not_allowed_key: 'not allowed value'
                 }
               }
        end

        it { is_expected.to redirect_to(site_youtube_channels_path(site)) }
        it { is_expected.to set_flash.to(/You have added USGovernment channel to this site/) }
      end

      context 'when channel URL is valid and it has already been added to the site' do
        let(:existing_youtube_profile) { mock_model(YoutubeProfile) }
        let(:new_youtube_profile) do
          mock_model(YoutubeProfile,
                     channel_id: 'us_government_channel_id',
                     title: 'USGovernment')
        end

        before do
          expect(YoutubeProfileData).to receive(:import_profile).
            with('youtube.com/channel/us_government_channel_id').
            and_return(existing_youtube_profile)
          youtube_profiles = double('youtube profiles')
          allow(site).to receive(:youtube_profiles).and_return(youtube_profiles)
          expect(youtube_profiles).to receive(:exists?).
            with(existing_youtube_profile.id).
            and_return(true)

          expect(YoutubeProfile).to receive(:new).
            with({ 'url' => 'youtube.com/channel/us_government_channel_id' }).
            and_return(new_youtube_profile)

          post :create,
               params: {
                 site_id: site.id,
                 youtube_profile: {
                   not_allowed_key: 'not allowed value',
                   url: 'youtube.com/channel/us_government_channel_id'
                 }
               }
        end

        it { is_expected.to assign_to(:profile).with(new_youtube_profile) }
        it { is_expected.to set_flash.now[:notice].to(/You have already added USGovernment channel to this site/) }
        it { is_expected.to render_template(:new) }
      end

      context 'when username is not valid' do
        let(:new_youtube_profile) { mock_model(YoutubeProfile, id: nil, new_record?: true) }

        before do
          expect(YoutubeProfileData).to receive(:import_profile).
            with('youtube.com/user/dgsearch').
            and_return(nil)
          expect(YoutubeProfile).to receive(:new).
            with({ 'url' => 'youtube.com/user/dgsearch' }).
            and_return(new_youtube_profile)

          post :create,
               params: { site_id: site.id,
                         youtube_profile: {
                           url: 'youtube.com/user/dgsearch',
                           not_allowed_key: 'not allowed value'
                         } }
        end

        it { is_expected.to assign_to(:profile).with(new_youtube_profile) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        youtube_profiles = double('youtube profiles')
        allow(site).to receive(:youtube_profiles).and_return(youtube_profiles)

        youtube_profile = mock_model(YoutubeProfile, title: 'usgovernment')
        expect(youtube_profiles).to receive(:find_by_id).with('100').
          and_return(youtube_profile)
        expect(youtube_profiles).to receive(:delete).with(youtube_profile)
        expect(youtube_profiles).
          to receive_message_chain(:reload, :exists?).and_return(false)
        expect(site).to receive(:disable_video_govbox!)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_youtube_channels_path(site)) }
      it { is_expected.to set_flash.to(/You have removed usgovernment channel from this site/) }
    end
  end
end
