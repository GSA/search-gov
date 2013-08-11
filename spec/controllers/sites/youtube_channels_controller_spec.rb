require 'spec_helper'

describe Sites::YoutubeChannelsController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:youtube_channels) { mock('youtube handles') }

      before do
        site.should_receive(:youtube_profiles).and_return(youtube_channels)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:youtube_channels).with(youtube_channels) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when username is valid and it has not been added to the site' do
        let(:youtube_channel) do
          mock_model(YoutubeProfile, username: 'USGovernment', new_record?: true)
        end

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).with({ 'username' => 'usgovernment'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).and_return(youtube_channel)
          youtube_channel.should_receive(:save).and_return(true)

          youtube_profiles = mock('youtube profiles')
          site.stub(:youtube_profiles).and_return(youtube_profiles)
          youtube_profiles.should_receive(:exists?).
              with(youtube_channel.id).
              and_return(false)
          youtube_profiles.should_receive(:<<).with(youtube_channel)
          RssFeed.should_receive(:enable_youtube_govbox!).with(site)

          post :create,
               site_id: site.id,
               youtube_channel: { username: 'usgovernment', not_allowed_key: 'not allowed value' }
        end

        it { should redirect_to(site_youtube_channels_path(site)) }
        it { should set_the_flash.to(/You have added USGovernment channel to this site/) }
      end

      context 'when username is valid and it has already been added to the site' do
        let(:existing_youtube_channel) { mock_model(YoutubeProfile) }
        let(:new_youtube_channel) { mock_model(YoutubeProfile, username: 'usgovernment') }

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).with({ 'username' => 'usgovernment'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).and_return(existing_youtube_channel)
          existing_youtube_channel.should_not_receive(:save)

          youtube_profiles = mock('youtube profiles')
          site.stub(:youtube_profiles).and_return(youtube_profiles)
          youtube_profiles.should_receive(:exists?).
              with(existing_youtube_channel.id).
              and_return(true)

          YoutubeProfile.should_receive(:new).
              with('username' => 'usgovernment').
              and_return(new_youtube_channel)

          post :create,
               site_id: site.id,
               youtube_channel: { username: 'usgovernment', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:youtube_channel).with(new_youtube_channel) }
        it { should set_the_flash[:notice].to(/You have already added usgovernment channel to this site/).now }
        it { should render_template(:new) }
      end

      context 'when username is not valid' do
        let(:new_youtube_channel) { mock_model(YoutubeProfile, id: nil, new_record?: true) }

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).
              with({ 'username' => 'invalid username'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).
              and_return(new_youtube_channel)
          new_youtube_channel.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               youtube_channel: { username: 'invalid username', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:youtube_channel).with(new_youtube_channel) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        youtube_profiles = mock('youtube profiles')
        site.stub(:youtube_profiles).and_return(youtube_profiles)

        youtube_channel = mock_model(YoutubeProfile, username: 'usgovernment')
        youtube_profiles.should_receive(:find_by_id).with('100').
            and_return(youtube_channel)
        youtube_profiles.should_receive(:delete).with(youtube_channel)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_youtube_channels_path(site)) }
      it { should set_the_flash.to(/You have removed usgovernment channel from this site/) }
    end
  end
end
