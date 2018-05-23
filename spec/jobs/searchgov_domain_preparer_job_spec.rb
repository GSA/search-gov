require 'spec_helper'

describe SearchgovDomainPreparerJob do
  let(:searchgov_domain) { SearchgovDomain.create(domain: 'agency.gov') }
  let(:args) do
    { searchgov_domain: searchgov_domain }
  end
  subject(:perform) { SearchgovDomainPreparerJob.perform_now(args) }

  before do
    allow(searchgov_domain).to receive(:check_status).and_return('200 OK')
  end

  it_behaves_like 'a searchgov job'

  it 'checks the domain status' do
    expect(searchgov_domain).to receive(:check_status)
    perform
  end

  it 'triggers sitemap indexing' do
    expect(SitemapIndexerJob).to receive(:perform_later).
      with(searchgov_domain: searchgov_domain)
    perform
  end
end
