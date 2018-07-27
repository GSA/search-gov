require 'spec_helper'

describe SearchgovDomainDestroyerJob do
  subject(:perform) { SearchgovDomainDestroyerJob.perform_now(args) }
  let(:domain) { 'www.archive.gov' }
  let!(:searchgov_domain) {
    SearchgovDomain.create(domain: domain, status: 200)
  }
  let(:args) {
    { searchgov_domain: searchgov_domain }
  }

  describe '#perform' do
    it 'requires a searchgov_domain as an argument' do
      expect{SearchgovDomainDestroyerJob.perform_now}.
        to raise_error(ArgumentError, 'missing keyword: searchgov_domain')
      perform
    end

    it 'destroys the searchgov domain' do
      expect(SearchgovDomain).to receive(:destroy)
      perform
      expect(SearchgovDomain.find_by(domain: domain)).to eq nil
    end

    context 'when the searchgov_domain contains searchgov_urls' do
      let(:url1) { 'https://www.archive.gov/info' }
      let(:url2) { 'https://www.archive.gov/hmmm' }
      let!(:searchgov_url1) { SearchgovUrl.create!(url: url1) }
      let!(:searchgov_url2) { SearchgovUrl.create!(url: url2) }

      it 'destroys the searchgov_urls in addition to the searchgov_domain' do
        expect(SearchgovDomain).to receive(:destroy)
        expect(SearchgovUrl).to receive(:destroy).twice
        perform
        expect(SearchgovUrl.find_by(url: url1)).to eq nil
        expect(SearchgovUrl.find_by(url: url2)).to eq nil
      end
    end
  end

  it_behaves_like 'a searchgov job'
end