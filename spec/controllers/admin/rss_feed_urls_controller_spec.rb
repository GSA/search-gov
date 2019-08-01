require 'spec_helper'

describe Admin::RssFeedUrlsController do
  fixtures :users, :affiliates, :memberships, :rss_feed_urls

  describe '#news_items' do
    context 'when logged in as an affiliate admin' do
      before do
        activate_authlogic
        UserSession.create(users('affiliate_admin'))
        @rss_feed_url = rss_feed_urls(:white_house_blog_url)
        get :news_items, params: { id: @rss_feed_url.id }
      end

      it { is_expected.to redirect_to admin_news_items_path(rss_feed_url_id: @rss_feed_url.id) }
    end
  end

  describe '#destroy_news_items' do
    let(:rss_feed_url) { mock_model(RssFeedUrl, url: 'https://search.gov/all.atom') }

    before do
      activate_authlogic
      UserSession.create(users('affiliate_admin'))
    end

    context 'all param is true' do
      it 'enqueues destroy news items' do
        expect(RssFeedUrl).to receive(:find).with('100').and_return(rss_feed_url)
        expect(rss_feed_url).to receive(:enqueue_destroy_news_items).with(:high)

        get :destroy_news_items, params: { id: '100', all: 'true' }
        expect(response.body).to match(/to delete #{rss_feed_url.url} news items./)
      end
    end

    context 'all param is not true' do
      it 'enqueues destroy news items with 404' do
        expect(RssFeedUrl).to receive(:find).with('100').and_return(rss_feed_url)
        expect(rss_feed_url).to receive(:enqueue_destroy_news_items_with_404).with(:high)

        get :destroy_news_items, params: { id: '100' }
        expect(response.body).to match(/to delete #{rss_feed_url.url} news items with status code 404./)
      end
    end
  end
end
