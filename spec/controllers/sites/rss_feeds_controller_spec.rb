# frozen_string_literal: true

describe Sites::RssFeedsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:rss_feeds) { double('rss feeds') }

      before do
        expect(site).to receive(:rss_feeds).and_return(rss_feeds)
        allow(rss_feeds).to receive(:order).and_return(rss_feeds)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:rss_feeds).with(rss_feeds) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when rss feed params are valid' do
        let(:rss_feed) { mock_model(RssFeed, name: 'Recalls') }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          allow(site).to receive(:rss_feeds).and_return(rss_feeds)
          expect(rss_feeds).to receive(:build).
            with({ 'name' => 'Recalls', 'show_only_media_content' => 'false' }).
            and_return(rss_feed)
          allow(RssFeedUrl).to receive_message_chain(:rss_feed_owned_by_affiliate,
                                                     :find_existing_or_initialize).
            and_return(rss_feed_url)
          expect(rss_feed).to receive(:rss_feed_urls=).with([rss_feed_url])

          expect(rss_feed).to receive(:save).and_return(true)

          post :create,
               params: {
                 site_id: site.id,
                 rss_feed: { name: 'Recalls',
                             show_only_media_content: 'false',
                             rss_feed_urls_attributes: {
                               '0': {
                                 url: 'some.agency.gov/news.atom'
                               }
                             },
                             not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:rss_feed).with(rss_feed) }
        it { is_expected.to redirect_to site_rss_feeds_path(site) }
        it { is_expected.to set_flash.to('You have added Recalls to this site.') }
      end

      context 'when rss feed params are not valid' do
        let(:rss_feed) { mock_model(RssFeed) }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          allow(site).to receive(:rss_feeds).and_return(rss_feeds)
          expect(rss_feeds).to receive(:build).
            with({ 'name' => 'Recalls', 'show_only_media_content' => 'false' }).
            and_return(rss_feed)
          allow(RssFeedUrl).to receive_message_chain(:rss_feed_owned_by_affiliate,
                                                     :find_existing_or_initialize).
            and_return(rss_feed_url)
          expect(rss_feed).to receive(:rss_feed_urls=).with([rss_feed_url])

          expect(rss_feed).to receive(:save).and_return(false)
          allow(rss_feed).to receive_message_chain(:rss_feed_urls, :build)

          post :create,
               params: {
                 site_id: site.id,
                 rss_feed: { name: 'Recalls',
                             show_only_media_content: 'false',
                             rss_feed_urls_attributes: {
                               '0': {
                                 url: 'some.agency.gov/news.atom'
                               }
                             },
                             not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:rss_feed).with(rss_feed) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when rss feed params are not valid' do
        let(:rss_feed) { mock_model(RssFeed, is_managed?: false) }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          allow(site).to receive(:rss_feeds).and_return(rss_feeds)
          expect(rss_feeds).to receive(:find_by).with(id: '100').and_return(rss_feed)

          expect(rss_feed).to receive(:assign_attributes).
            with({ 'name' => 'Recalls', 'show_only_media_content' => 'false' })
          allow(RssFeedUrl).to receive_message_chain(:rss_feed_owned_by_affiliate,
                                                     :find_existing_or_initialize).
            and_return(rss_feed_url)
          expect(rss_feed).to receive(:rss_feed_urls=).with([rss_feed_url])

          expect(rss_feed).to receive(:save).and_return(false)
          allow(rss_feed).to receive_message_chain(:rss_feed_urls, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                rss_feed: { name: 'Recalls',
                            show_only_media_content: 'false',
                            rss_feed_urls_attributes: { '0' => { url: 'some.agency.gov/news.atom' } },
                            not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:rss_feed).with(rss_feed) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        rss_feeds = double('rss feeds')
        allow(site).to receive(:rss_feeds).and_return(rss_feeds)

        rss_feed = mock_model(RssFeed, name: 'Recalls')
        allow(rss_feeds).to receive_message_chain(:non_managed, :find_by).with(id: '100').and_return(rss_feed)
        expect(rss_feed).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_rss_feeds_path(site)) }
      it { is_expected.to set_flash.to(/You have removed Recalls from this site/) }
    end
  end
end
