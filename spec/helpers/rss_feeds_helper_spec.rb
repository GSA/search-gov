require 'spec_helper'

describe RssFeedsHelper do
  fixtures :rss_feeds, :affiliates

  let(:rss_feed) { rss_feeds(:usagov_blog) }
  let(:site) { rss_feed.owner }

  describe '#link_to_preview_rss_feed' do
    let(:preview_link) do
      "a[href=\"http://test.host/search/news?affiliate=usagov&channel=#{rss_feed.id}\"][target=\"_blank\"]"
    end

    it 'returns the preview link' do
      expect(helper.link_to_preview_rss_feed(site, rss_feed)).to have_selector(preview_link, text: 'Preview')
    end
  end
end
