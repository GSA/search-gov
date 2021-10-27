# frozen_string_literal: true

describe 'RssFeedUrls', :js do
  let(:url) { '/admin/rss_feed_urls' }
  let(:downloaded_csv) { 'rss_feed_urls.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page',
                  %w[Show],
                  'Rss Feed Urls'
  it_behaves_like 'a Search'
  it_behaves_like 'a CSV export'
end
