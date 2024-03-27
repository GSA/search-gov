require 'spec_helper'

describe SearchgovDomainDestroyerJob do
  subject(:perform) { described_class.perform_now(searchgov_domain) }

  let(:searchgov_domain) { SearchgovDomain.create(domain: 'www.archive.gov', status: '200 OK') }
  let(:delay) { 10 }

  before do
    SearchgovDomainIndexerJob.perform_later(searchgov_domain: searchgov_domain, delay: delay)
    allow(Resque::Job).to receive(:destroy).and_call_original
    allow(searchgov_domain).to receive(:delay).and_return(delay)
  end

  describe '#perform' do
    it 'requires a searchgov_domain as an argument' do
      expect { described_class.perform_now }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
    end

    it 'destroys the searchgov domain' do
      perform
      expect(SearchgovDomain.exists?(searchgov_domain.id)).to be false
    end

    it 'removes the domain indexing job from the queue' do
      perform
      expect(Resque::Job).to have_received(:destroy).with('searchgov',
                                                          'SearchgovDomainIndexerJob',
                                                          searchgov_domain_id: searchgov_domain.id,
                                                          delay: delay)
    end

    it 'ensures the queue is empty for this domain after execution' do
      perform
      expect(Resque.size('searchgov')).to eq(0)
    end

    context 'when the searchgov_domain has associated searchgov_url records' do
      let!(:searchgov_url1) { searchgov_domain.searchgov_urls.create(url: 'https://www.archive.gov/info', hashed_url: 'hash1') }
      let!(:searchgov_url2) { searchgov_domain.searchgov_urls.create(url: 'https://www.archive.gov/hmmm', hashed_url: 'hash2') }

      it 'destroys all associated searchgov_urls' do
        perform
        expect(SearchgovUrl.exists?(searchgov_url1.id)).to be false
        expect(SearchgovUrl.exists?(searchgov_url2.id)).to be false
      end
    end

    context 'when SearchgovDomain destruction fails' do
      before do
        allow(searchgov_domain).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
      end

      it 'raises an exception if domain destruction fails' do
        expect { perform }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end
end
