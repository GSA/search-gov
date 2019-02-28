require 'spec_helper'

describe SitemapMonitorJob do
  let(:searchgov_domain) { instance_double(SearchgovDomain) }
  subject(:perform) { SitemapMonitorJob.perform_now }

  it_behaves_like 'a searchgov job'

  context 'when domains can be indexed' do
    before do
      allow(SearchgovDomain).to receive(:ok).and_return([searchgov_domain])
    end

    it 'indexes sitemaps' do
      expect(searchgov_domain).to receive(:index_sitemaps)
      perform
    end
  end
end
