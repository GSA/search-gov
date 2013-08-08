require 'spec_helper'

describe Sites::FlickrUrlsController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:flickr_urls) { mock('flickr_urls') }

      before do
        site.should_receive(:flickr_profiles).and_return(flickr_urls)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:flickr_urls).with(flickr_urls) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Flickr URL params are valid' do
        let(:flickr_url) { mock_model(FlickrProfile, url: 'http://www.flickr.com/groups/usagov/') }

        before do
          flickr_profiles = mock('flickr profiles')
          site.stub(:flickr_profiles).and_return(flickr_profiles)
          flickr_profiles.should_receive(:build).
              with('url' => 'http://www.flickr.com/groups/usagov/').
              and_return(flickr_url)

          flickr_url.should_receive(:save).and_return(true)

          post :create,
               site_id: site.id,
               flickr_url: { url: 'http://www.flickr.com/groups/usagov/', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:flickr_url).with(flickr_url) }
        it { should redirect_to site_flickr_urls_path(site) }
        it { should set_the_flash.to('You have added www.flickr.com/groups/usagov/ to this site.') }
      end

      context 'when Flickr URL params are not valid' do
        let(:flickr_url) { mock_model(FlickrProfile, url: 'usagov') }

        before do
          flickr_profiles = mock('flickr profiles')
          site.stub(:flickr_profiles).and_return(flickr_profiles)
          flickr_profiles.should_receive(:build).
              with('url' => 'usagov').
              and_return(flickr_url)

          flickr_url.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               flickr_url: { url: 'usagov', not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:flickr_url).with(flickr_url) }
        it { should render_template(:new) }
      end
    end
  end
end
