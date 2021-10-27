# frozen_string_literal: true

describe 'RssFeeds', :js do
  let(:url) { '/admin/rss_feeds' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'
end
