require 'spec_helper'

describe Sites::SiteFeedUrlsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
    it_should_behave_like 'restricted to approved user', :get, :edit

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:site_feed_url) { mock_model(SiteFeedUrl) }

      before do
        site.should_receive(:site_feed_url).and_return(site_feed_url)
        get :edit, site_id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:site_feed_url).with(site_feed_url) }
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Site Feed URL params are valid' do
        let(:site_feed_url) { mock_model(SiteFeedUrl) }

        before do
          site.should_receive(:site_feed_url).and_return(site_feed_url)
          site_feed_url.should_receive(:update_attributes).
              with('rss_url' => 'http://usasearch.howto.gov/all.atom',
                   'last_checked_at' => nil,
                   'last_fetch_status' => 'Pending').
              and_return(true)

          Resque.should_receive(:enqueue_with_priority).
              with(:high, SiteFeedUrlFetcher, site_feed_url.id)

          put :update,
               site_id: site.id,
               site_feed_url: { rss_url: 'http://usasearch.howto.gov/all.atom',
                                not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:site_feed_url).with(site_feed_url) }
        it { should redirect_to edit_site_supplemental_feed_path(site) }
        it { should set_the_flash.to('You have updated your supplemental feed for this site.') }
      end

      context 'when Site Feed URL params are not valid' do
        let(:site_feed_url) { mock_model(SiteFeedUrl) }

        before do
          site.stub(:site_feed_url).and_return(site_feed_url)
          site_feed_url.should_receive(:update_attributes).
              with('rss_url' => '',
                   'last_checked_at' => nil,
                   'last_fetch_status' => 'Pending').
              and_return(false)

          put :update,
              site_id: site.id,
              site_feed_url: { rss_url: '',
                               not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:site_feed_url).with(site_feed_url) }
        it { should render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        site_feed_url = mock_model(SiteFeedUrl)
        site.should_receive(:site_feed_url).and_return(site_feed_url)
        site_feed_url.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(edit_site_supplemental_feed_path(site)) }
      it { should set_the_flash.to('You have removed your supplemental feed from this site.') }
    end
  end
end
