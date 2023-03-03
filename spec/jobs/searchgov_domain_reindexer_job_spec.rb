require 'spec_helper'

describe SearchgovDomainReindexerJob do
  subject(:perform) { described_class.perform_now(**args) }

  let(:searchgov_domain) { searchgov_domains(:basic_domain) }
  let(:args) do
    { searchgov_domain: searchgov_domain }
  end

  it_behaves_like 'a searchgov job'

  context 'when the domain has indexed URLs' do
    let!(:indexed_url) do
      searchgov_domain.searchgov_urls.create!(url: 'https://foo.gov/ok',
                                              last_crawl_status: 'OK')
    end
    let!(:failed_url) do
      searchgov_domain.searchgov_urls.create!(url: 'https://foo.gov/failed',
                                              last_crawl_status: 'failed')
    end

    it 'sets the previously indexed URLs to be reindexed' do
      expect { perform }.
        to change { indexed_url.reload.enqueued_for_reindex }.from(false).to(true)
    end

    it 'does not set previously failed URLs to be reindexed' do
      expect { perform }.not_to change { failed_url.reload.enqueued_for_reindex }
    end
  end

  it 'triggers sitemap indexing' do
    expect(searchgov_domain).to receive(:index_sitemaps)
    perform
  end
end
