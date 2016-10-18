require 'spec_helper'

describe Sites::RssFeedsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:rss_feeds) { double('rss feeds') }

      before do
        site.should_receive(:rss_feeds).and_return(rss_feeds)
        get :index, id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:rss_feeds).with(rss_feeds) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when rss feed params are valid' do
        let(:rss_feed) { mock_model(RssFeed, name: 'Recalls') }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          site.stub(:rss_feeds).and_return(rss_feeds)
          rss_feeds.should_receive(:build).
              with('name' => 'Recalls', 'show_only_media_content' => 'false').
              and_return(rss_feed)
          RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate,
                                :find_existing_or_initialize).
              and_return(rss_feed_url)
          rss_feed.should_receive(:rss_feed_urls=).with([rss_feed_url])

          rss_feed.should_receive(:save).and_return(true)

          post :create,
               site_id: site.id,
               rss_feed: { name: 'Recalls',
                           show_only_media_content: 'false',
                           rss_feed_urls_attributes: { '0' => { url: 'some.agency.gov/news.atom' } },
                           not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:rss_feed).with(rss_feed) }
        it { should redirect_to site_rss_feeds_path(site) }
        it { should set_flash.to('You have added Recalls to this site.') }
      end

      context 'when rss feed params are not valid' do
        let(:rss_feed) { mock_model(RssFeed) }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          site.stub(:rss_feeds).and_return(rss_feeds)
          rss_feeds.should_receive(:build).
              with('name' => 'Recalls', 'show_only_media_content' => 'false').
              and_return(rss_feed)
          RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate,
                                :find_existing_or_initialize).
              and_return(rss_feed_url)
          rss_feed.should_receive(:rss_feed_urls=).with([rss_feed_url])

          rss_feed.should_receive(:save).and_return(false)
          rss_feed.stub_chain(:rss_feed_urls, :build)

          post :create,
               site_id: site.id,
               rss_feed: { name: 'Recalls',
                           show_only_media_content: 'false',
                           rss_feed_urls_attributes: { '0' => { url: 'some.agency.gov/news.atom' } },
                           not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:rss_feed).with(rss_feed) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when rss feed params are not valid' do
        let(:rss_feed) { mock_model(RssFeed, is_managed?: false) }
        let(:rss_feed_url) { mock_model(RssFeedUrl, new_record?: false) }

        before do
          rss_feeds = double('rss feeds')
          site.stub(:rss_feeds).and_return(rss_feeds)
          rss_feeds.should_receive(:find_by_id).with('100').and_return(rss_feed)

          rss_feed.should_receive(:assign_attributes).
              with('name' => 'Recalls', 'show_only_media_content' => 'false')
          RssFeedUrl.stub_chain(:rss_feed_owned_by_affiliate,
                                :find_existing_or_initialize).
              and_return(rss_feed_url)
          rss_feed.should_receive(:rss_feed_urls=).with([rss_feed_url])

          rss_feed.should_receive(:save).and_return(false)
          rss_feed.stub_chain(:rss_feed_urls, :build)

          put :update,
              site_id: site.id,
              id: 100,
              rss_feed: { name: 'Recalls',
                          show_only_media_content: 'false',
                          rss_feed_urls_attributes: { '0' => { url: 'some.agency.gov/news.atom' } },
                          not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:rss_feed).with(rss_feed) }
        it { should render_template(:edit) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        rss_feeds = double('rss feeds')
        site.stub(:rss_feeds).and_return(rss_feeds)

        rss_feed = mock_model(RssFeed, name: 'Recalls')
        rss_feeds.stub_chain(:non_managed, :find_by_id).with('100').and_return(rss_feed)
        rss_feed.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_rss_feeds_path(site)) }
      it { should set_flash.to(/You have removed Recalls from this site/) }
    end
  end
end
