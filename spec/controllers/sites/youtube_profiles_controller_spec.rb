require 'spec_helper'

describe Sites::YoutubeProfilesController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:youtube_profiles) { mock('youtube profiles') }

      before do
        site.should_receive(:youtube_profiles).and_return(youtube_profiles)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:youtube_profiles).with(youtube_profiles) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when username is valid and it has not been added to the site' do
        let(:youtube_profile) do
          mock_model(YoutubeProfile, username: 'USGovernment', new_record?: true)
        end

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).with({ 'username' => 'usgovernment'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).and_return(youtube_profile)
          youtube_profile.should_receive(:save).and_return(true)

          youtube_profiles = mock('youtube profiles')
          site.stub(:youtube_profiles).and_return(youtube_profiles)
          youtube_profiles.should_receive(:exists?).
              with(youtube_profile.id).
              and_return(false)
          youtube_profiles.should_receive(:<<).with(youtube_profile)
          RssFeed.should_receive(:enable_youtube_govbox!).with(site)

          post :create,
               site_id: site.id,
               youtube_profile: { username: 'usgovernment', not_allowed_key: 'not allowed value' }
        end

        it { should redirect_to(site_youtube_usernames_path(site)) }
        it { should set_the_flash.to(/You have added USGovernment to this site/) }
      end

      context 'when username is valid and it has already been added to the site' do
        let(:existing_youtube_profile) { mock_model(YoutubeProfile) }
        let(:new_youtube_profile) { mock_model(YoutubeProfile, username: 'usgovernment') }

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).with({ 'username' => 'usgovernment'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).and_return(existing_youtube_profile)
          existing_youtube_profile.should_not_receive(:save)

          youtube_profiles = mock('youtube profiles')
          site.stub(:youtube_profiles).and_return(youtube_profiles)
          youtube_profiles.should_receive(:exists?).
              with(existing_youtube_profile.id).
              and_return(true)

          YoutubeProfile.should_receive(:new).
              with('username' => 'usgovernment').
              and_return(new_youtube_profile)

          post :create,
               site_id: site.id,
               youtube_profile: { username: 'usgovernment', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:youtube_profile).with(new_youtube_profile) }
        it { should set_the_flash[:notice].to(/You have already added usgovernment to this site/).now }
        it { should render_template(:new) }
      end

      context 'when username is not valid' do
        let(:new_youtube_profile) { mock_model(YoutubeProfile, id: nil, new_record?: true) }

        before do
          where_results = mock('where results')
          YoutubeProfile.should_receive(:where).
              with({ 'username' => 'invalid username'}).
              and_return(where_results)
          where_results.should_receive(:first_or_initialize).
              and_return(new_youtube_profile)
          new_youtube_profile.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               youtube_profile: { username: 'invalid username', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:youtube_profile).with(new_youtube_profile) }
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

        youtube_profile = mock_model(YoutubeProfile, username: 'usgovernment')
        youtube_profiles.should_receive(:find_by_id).with('100').
            and_return(youtube_profile)
        youtube_profiles.should_receive(:delete).with(youtube_profile)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_youtube_usernames_path(site)) }
      it { should set_the_flash.to(/You have removed usgovernment from this site/) }
    end
  end
end
