require 'spec_helper'

describe SearchgovDomainPreparerJob do
  subject(:perform) { described_class.perform_now(**args) }

  let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:args) do
    { searchgov_domain: searchgov_domain }
  end

  before do
    allow(searchgov_domain).to receive(:check_status).and_return('200 OK')
  end

  it_behaves_like 'a searchgov job'

  it 'checks the domain status' do
    expect(searchgov_domain).to receive(:check_status)
    perform
  end

  it 'triggers sitemap indexing' do
    expect(searchgov_domain).to receive(:index_sitemaps)
    perform
  end
end
