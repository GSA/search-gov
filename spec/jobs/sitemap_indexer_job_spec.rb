require 'spec_helper'

describe SitemapIndexerJob do
  let(:domain) { 'agency.gov' }
  let(:sitemap_url) { "https://#{domain}/sitemap.xml" }
  let(:args) do
    { sitemap_url: sitemap_url, domain: domain }
  end
  let(:indexer) { instance_double(SitemapIndexer) }
  subject(:perform) { described_class.perform_now(args) }

  it_behaves_like 'a sitemap job'
  it_behaves_like 'a unique job'

  it 'indexes the sitemap' do
    allow(SitemapIndexer).to receive(:new).with(args).and_return(indexer)
    expect(indexer).to receive(:index)
    perform
  end
end
