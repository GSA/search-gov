# frozen_string_literal: true

describe 'SuperfreshUrls', :js do
  let(:url) { '/admin/superfresh_urls' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'SuperfreshUrls'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
