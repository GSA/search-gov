require 'spec_helper'

describe SearchgovDomainDestroyerJob do
  subject(:perform) { described_class.perform_now(searchgov_domain) }

  let!(:searchgov_domain) { SearchgovDomain.create!(domain: 'www.archive.gov', status: '200 OK') }

  describe '#perform' do
    it 'requires a searchgov_domain as an argument' do
      expect { described_class.perform_now }.to raise_error(ArgumentError)
    end

    it 'destroys the searchgov domain' do
      perform
      expect(SearchgovDomain.exists?(searchgov_domain.id)).to be(false)
    end

    context 'when the searchgov_domain has associated searchgov_url records' do
      before do
        allow(SearchgovUrl).to receive(:find_each).and_yield(searchgov_url1).and_yield(searchgov_url2)
      end

      let!(:searchgov_url1) { searchgov_domain.searchgov_urls.create!(url: 'https://www.archive.gov/info', hashed_url: 'hash1') }
      let!(:searchgov_url2) { searchgov_domain.searchgov_urls.create!(url: 'https://www.archive.gov/hmmm', hashed_url: 'hash2') }

      it 'destroys all associated searchgov_urls' do
        perform
        expect(SearchgovUrl.exists?(searchgov_url1.id)).to be(false)
        expect(SearchgovUrl.exists?(searchgov_url2.id)).to be(false)
      end
    end

    context 'with an acceptable number of URLs' do
      let(:batch) { 10_000 }
      before do
        batch.times do |n|
          searchgov_domain.searchgov_urls.create!(url: "https://www.archive.gov/page#{n}", hashed_url: "hash#{n}")
        end
      end

      it 'handles large domains without timing out', :aggregate_failures do
        expect { perform }.not_to raise_error
        expect(SearchgovDomain.exists?(searchgov_domain.id)).to be(false)
        expect(SearchgovUrl.where(searchgov_domain_id: searchgov_domain.id).count).to eq(0)
      end
    end
  end

  it_behaves_like 'a searchgov job'
end
