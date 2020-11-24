require 'spec_helper'

describe SearchgovDomainIndexerJob do
  subject(:perform) { SearchgovDomainIndexerJob.perform_now(args) }

  let!(:searchgov_domain) do
    searchgov_domain = SearchgovDomain.find_by(domain: 'agency.gov')
    searchgov_domain.update(status: '200', activity: 'indexing')
    searchgov_domain
  end

  let(:args) do
    { searchgov_domain: searchgov_domain, delay: 10 }
  end

  it_behaves_like 'a searchgov job'

  context 'when a domain has unfetched urls' do
    let!(:searchgov_url) { SearchgovUrl.create(url: 'https://agency.gov/') }

    it 'fetches the url' do
      perform
      expect(searchgov_url.reload.last_crawl_status).not_to be nil
    end

    it 'transitions the domain activity back to "idle"' do
      expect{ perform }.to change{ searchgov_domain.activity }.
        from('indexing').to('idle')
    end

    context 'when the domain has multiple unfetched urls' do
      let!(:another_searchgov_url) { SearchgovUrl.create(url: 'https://agency.gov/another') }

      before { travel_to(Time.now) }

      after { travel_back }

      it 'enqueues the next job after the specified delay' do
        expect{ perform }.to have_enqueued_job(SearchgovDomainIndexerJob).
          with(searchgov_domain: searchgov_domain, delay: 10).at(10.seconds.from_now)
      end
    end
  end

  context 'when a domain has outdated urls' do
    let!(:searchgov_url) do
      SearchgovUrl.create!(url: 'https://agency.gov/', last_crawled_at: 1.week.ago, lastmod: 1.day.ago)
    end

    it 'fetches the url' do
      expect{ perform }.to change{ searchgov_url.reload.last_crawled_at }
    end
  end

  context 'when a domain has no unfetched urls' do
    it 'does not raise an error' do
      expect{ perform }.not_to raise_error
    end

    it 'does not enqueue subsequent jobs' do
      expect{ perform }.not_to have_enqueued_job(SearchgovDomainIndexerJob)
    end
  end
end
