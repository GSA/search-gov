# frozen_string_literal: true

describe 'SiteFeedUrls', :js do
  let(:url) { '/admin/site_feed_urls' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is a SiteFeedurl' do
    before do
      SiteFeedUrl.create(affiliate: Affiliate.first,
                         rss_url: 'https://test.gov')
    end

    it_behaves_like 'an ActiveScaffold page',
                    %w[Show],
                    'SiteFeedUrls'
  end

  it_behaves_like 'a Search'
end
