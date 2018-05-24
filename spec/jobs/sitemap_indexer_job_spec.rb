require 'spec_helper'

describe SitemapIndexerJob do
  let!(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov') }
  let(:args) do
    { searchgov_domain: searchgov_domain }
  end
  subject(:perform) { SitemapIndexerJob.perform_now(args) }

  it_behaves_like 'a searchgov job'

  it 'indexes the sitemap' do
    expect(searchgov_domain).to receive(:index_sitemap)
    perform
  end
end
