require 'spec_helper'

describe SearchgovDomainIndexerJob do
  subject(:perform) { SearchgovDomainIndexerJob.perform_now(args) }

  let!(:searchgov_domain) do
    SearchgovDomain.create(domain: 'agency.gov', status: '200', activity: 'indexing')
  end
  let(:args) do
    { searchgov_domain: searchgov_domain, delay: 10, start: start, conditions: fetch_required }
  end
  let(:start) { 1.minute.ago.to_s }
  let(:fetch_required) { 'last_crawled_at IS NULL OR lastmod > last_crawled_at' }

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
      before { Timecop.freeze }
      after { Timecop.return }

      it 'enqueues the next job after the specified delay' do
        expect{ perform }.to have_enqueued_job(SearchgovDomainIndexerJob).
          with(searchgov_domain: searchgov_domain, delay: 10, conditions: fetch_required, start: start )
            .at(10.seconds.from_now)
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

  context 'when indexing only URLs meeting specific conditions' do
    let!(:ok_url) do
      SearchgovUrl.create!(url: 'https://agency.gov/', last_crawled_at: 1.week.ago, last_crawl_status: 'OK')
    end
    let!(:failed_url) do
      SearchgovUrl.create!(url: 'https://agency.gov/404', last_crawled_at: 1.week.ago, last_crawl_status: '404')
    end
    let(:args) do
      { searchgov_domain: searchgov_domain, delay: 10, conditions: { last_crawl_status: '404' }, start: start }
    end

    it 'fetches the specified URLs' do
      expect{ perform }.to change{ failed_url.reload.last_crawled_at }
    end

    it 'does not fetch the URLs that do not meet the conditions ' do
      expect{ perform }.to change{ failed_url.reload.last_crawled_at }
    end

    context 'when multiple URLs need to be fetched' do
      let!(:another_404) do
        SearchgovUrl.create!(url: 'https://agency.gov/404_b', last_crawled_at: 1.week.ago, last_crawl_status: '404')
      end

      it 'enqueues another job' do
        puts "before #{searchgov_domain.attributes}"
        expect{ perform }.to have_enqueued_job(SearchgovDomainIndexerJob).
          with(searchgov_domain: searchgov_domain, delay: 10, conditions: { last_crawl_status: '404' }, start: start)
        puts "after #{searchgov_domain.attributes}"
      end
    end

    context 'when re-fetching does not change the record conditions' do
      before do
        stub_request(:get, failed_url.url).to_return(status: 404)
      end

      it 'does not loop endlessly' do
        expect{ perform }.not_to have_enqueued_job(SearchgovDomainIndexerJob)
      end
    end
  end
end
