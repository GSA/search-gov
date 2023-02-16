require 'spec_helper'

describe Sites::SiteFeedUrlsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:site_feed_url) { mock_model(SiteFeedUrl) }

      before do
        expect(site).to receive(:site_feed_url).and_return(site_feed_url)
        get :edit, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:site_feed_url).with(site_feed_url) }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Site Feed URL params are valid' do
        let(:site_feed_url) { mock_model(SiteFeedUrl) }

        before do
          expect(site).to receive(:site_feed_url).and_return(site_feed_url)
          expect(site_feed_url).to receive(:update).
            with({ 'rss_url' => 'http://search.gov/all.atom',
                   'last_checked_at' => nil,
                   'last_fetch_status' => 'Pending' }).
            and_return(true)

          expect(Resque).to receive(:enqueue_with_priority).
            with(:high, SiteFeedUrlFetcher, site_feed_url.id)

          put :update,
              params: {
                site_id: site.id,
                site_feed_url: { rss_url: 'http://search.gov/all.atom',
                                 not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:site_feed_url).with(site_feed_url) }
        it { is_expected.to redirect_to edit_site_supplemental_feed_path(site) }
        it { is_expected.to set_flash.to('You have updated your supplemental feed for this site.') }
      end

      context 'when Site Feed URL params are not valid' do
        let(:site_feed_url) { mock_model(SiteFeedUrl) }

        before do
          allow(site).to receive(:site_feed_url).and_return(site_feed_url)
          expect(site_feed_url).to receive(:update).
            with({ 'rss_url' => '',
                   'last_checked_at' => nil,
                   'last_fetch_status' => 'Pending' }).
            and_return(false)

          put :update,
              params: {
                site_id: site.id,
                site_feed_url: { rss_url: '',
                                 not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:site_feed_url).with(site_feed_url) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        site_feed_url = mock_model(SiteFeedUrl)
        expect(site).to receive(:site_feed_url).and_return(site_feed_url)
        expect(site_feed_url).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(edit_site_supplemental_feed_path(site)) }
      it { is_expected.to set_flash.to('You have removed your supplemental feed from this site.') }
    end
  end
end
