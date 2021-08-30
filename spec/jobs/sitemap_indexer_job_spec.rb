require 'spec_helper'
#test another violation

describe SitemapIndexerJob do
  let(:sitemap_url) { 'https://agency.gov/sitemap.xml' }
  let(:args) do
    { sitemap_url: sitemap_url }
  end
  let(:indexer) { instance_double(SitemapIndexer) }
  subject(:perform) { described_class.perform_now(args) }

  it_behaves_like 'a sitemap job'

  it 'indexes the sitemap' do
    allow(SitemapIndexer).to receive(:new).with(args).and_return(indexer)
    expect(indexer).to receive(:index)
    perform
  end
end
