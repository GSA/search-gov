require 'spec_helper'

describe Sites::FlickrProfilesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:flickr_profiles) { double('flickr profiles') }

      before do
        site.should_receive(:flickr_profiles).and_return(flickr_profiles)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:flickr_profiles).with(flickr_profiles) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Flickr URL params are valid' do
        let(:flickr_profile) { mock_model(FlickrProfile, url: 'http://www.flickr.com/groups/usagov/') }

        before do
          flickr_profiles = double('flickr profiles')
          site.stub(:flickr_profiles).and_return(flickr_profiles)
          flickr_profiles.should_receive(:build).
              with('url' => 'http://www.flickr.com/groups/usagov/').
              and_return(flickr_profile)

          flickr_profile.should_receive(:save).and_return(true)

          post :create,
               site_id: site.id,
               flickr_profile: { url: 'http://www.flickr.com/groups/usagov/', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:flickr_profile).with(flickr_profile) }
        it { should redirect_to site_flickr_urls_path(site) }
        it { should set_flash.to('You have added www.flickr.com/groups/usagov/ to this site.') }
      end

      context 'when Flickr URL params are not valid' do
        let(:flickr_profile) { mock_model(FlickrProfile, url: 'usagov') }

        before do
          flickr_profiles = double('flickr profiles')
          site.stub(:flickr_profiles).and_return(flickr_profiles)
          flickr_profiles.should_receive(:build).
              with('url' => 'usagov').
              and_return(flickr_profile)

          flickr_profile.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               flickr_profile: { url: 'usagov', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:flickr_profile).with(flickr_profile) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        flickr_profiles = double('flickr profiles')
        site.stub(:flickr_profiles).and_return(flickr_profiles)

        flickr_profile = mock_model(FlickrProfile, url: 'http://www.flickr.com/groups/usagov/')
        flickr_profiles.should_receive(:find_by_id).with('100').
            and_return(flickr_profile)
        flickr_profile.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_flickr_urls_path(site)) }
      it { should set_flash.to(%r[You have removed www.flickr.com/groups/usagov/ from this site]) }
    end
  end
end
