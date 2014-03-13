require 'spec_helper'

describe Admin::RssFeedUrlsController do
  fixtures :users, :affiliates, :memberships


  describe '#destroy_news_items' do
    let(:rss_feed_url) { mock_model(RssFeedUrl, url: 'http://search.digitalgov.gov/all.atom') }

    before do
      activate_authlogic
      UserSession.create({ email: users('affiliate_admin').email, password: 'admin' })
    end

    context 'all param is true' do
      it 'enqueues destroy news items' do
        RssFeedUrl.should_receive(:find).with('100').and_return(rss_feed_url)
        rss_feed_url.should_receive(:enqueue_destroy_news_items).with(:high)

        get :destroy_news_items, id: '100', all: 'true'
        response.body.should contain("to delete #{rss_feed_url.url} news items.")
      end
    end

    context 'all param is not true' do
      it 'enqueues destroy news items with 404' do
        RssFeedUrl.should_receive(:find).with('100').and_return(rss_feed_url)
        rss_feed_url.should_receive(:enqueue_destroy_news_items_with_404).with(:high)

        get :destroy_news_items, id: '100'
        response.body.should contain("to delete #{rss_feed_url.url} news items with status code 404.")
      end
    end
  end
end
