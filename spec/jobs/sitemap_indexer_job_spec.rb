require 'spec_helper'

describe SitemapIndexerJob do
  let!(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov') }
  let(:args) do
    { searchgov_domain: searchgov_domain }
  end
  let(:indexer) { instance_double(SitemapIndexer) }
  subject(:perform) { SitemapIndexerJob.perform_now(args) }

  it_behaves_like 'a searchgov job'

  it 'indexes the sitemap' do
    allow(SitemapIndexer).to receive(:new).with(args).and_return(indexer)
    expect(indexer).to receive(:index)
    perform
  end
end
