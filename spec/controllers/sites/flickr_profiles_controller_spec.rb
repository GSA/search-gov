require 'spec_helper'

describe Sites::FlickrProfilesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:flickr_profiles) { double('flickr profiles') }

      before do
        expect(site).to receive(:flickr_profiles).and_return(flickr_profiles)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:flickr_profiles).with(flickr_profiles) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Flickr URL params are valid' do
        let(:flickr_profile) { mock_model(FlickrProfile, url: 'http://www.flickr.com/groups/usagov/') }

        before do
          flickr_profiles = double('flickr profiles')
          allow(site).to receive(:flickr_profiles).and_return(flickr_profiles)
          expect(flickr_profiles).to receive(:build).
            with({ 'url' => 'http://www.flickr.com/groups/usagov/' }).
            and_return(flickr_profile)

          expect(flickr_profile).to receive(:save).and_return(true)

          post :create,
               params: {
                 site_id: site.id,
                 flickr_profile: { url: 'http://www.flickr.com/groups/usagov/',
                                   not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:flickr_profile).with(flickr_profile) }
        it { is_expected.to redirect_to site_flickr_urls_path(site) }
        it { is_expected.to set_flash.to('You have added www.flickr.com/groups/usagov/ to this site.') }
      end

      context 'when Flickr URL params are not valid' do
        let(:flickr_profile) { mock_model(FlickrProfile, url: 'usagov') }

        before do
          flickr_profiles = double('flickr profiles')
          allow(site).to receive(:flickr_profiles).and_return(flickr_profiles)
          expect(flickr_profiles).to receive(:build).
            with({ 'url' => 'usagov' }).
            and_return(flickr_profile)

          expect(flickr_profile).to receive(:save).and_return(false)

          post :create,
               params: {
                 site_id: site.id,
                 flickr_profile: { url: 'usagov',
                                   not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:flickr_profile).with(flickr_profile) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        flickr_profiles = double('flickr profiles')
        allow(site).to receive(:flickr_profiles).and_return(flickr_profiles)

        flickr_profile = mock_model(FlickrProfile, url: 'http://www.flickr.com/groups/usagov/')
        expect(flickr_profiles).to receive(:find_by_id).with('100').
          and_return(flickr_profile)
        expect(flickr_profile).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_flickr_urls_path(site)) }
      it { is_expected.to set_flash.to(%r{You have removed www.flickr.com/groups/usagov/ from this site}) }
    end
  end
end
