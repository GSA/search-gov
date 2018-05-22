require 'spec_helper'

describe SitemapIndexerJob do
  let(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov') }
  subject(:perform) { SitemapIndexerJob.perform_now(searchgov_domain) }

  it 'uses the "searchgov" queue' do
    expect{
      SitemapIndexerJob.perform_later(searchgov_domain)
    }.to have_enqueued_job.on_queue('searchgov')
  end

  it 'indexes the sitemap' do
    expect(searchgov_domain).to receive(:index_sitemap)
    perform
  end
end
