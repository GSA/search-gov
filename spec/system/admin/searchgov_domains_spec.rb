# frozen_string_literal: true

describe 'Search.gov Domains', :js do
  let(:url) { '/admin/searchgov_domains' }
  let(:downloaded_csv) { 'searchgov_domains.csv' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is a domain' do
    before { SearchgovDomain.create(domain: 'test.gov') }

    it_behaves_like 'an ActiveScaffold page', %w[URLs Sitemaps], 'Search.gov Domains'
  end

  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
