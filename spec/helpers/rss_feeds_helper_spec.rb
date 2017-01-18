require 'spec_helper'

describe RssFeedsHelper do
  fixtures :rss_feeds, :affiliates

  let(:rss_feed) { rss_feeds(:usagov_blog) }
  let(:site) { rss_feed.owner }

  describe "#link_to_preview_rss_feed" do
    let(:preview_link) do
      "<a href=\"http://test.host/search/news?affiliate=usagov&amp;channel=#{rss_feed.id}\" target=\"_blank\">Preview</a>"
    end

    it 'returns the preview link' do
      expect(helper.link_to_preview_rss_feed(site, rss_feed)).to eq preview_link
    end

    context 'when the site is search consumer enabled' do
      before { site.update_attribute(:search_consumer_search_enabled, true) }

      let(:preview_link) do
        "<a href=\"http://test.host/c/search/rss?affiliate=usagov&amp;channel=#{rss_feed.id}\" target=\"_blank\">Preview</a>"
      end

      it 'returns the sc preview link' do
        expect(helper.link_to_preview_rss_feed(site, rss_feed)).to eq preview_link
      end
    end
  end
end
