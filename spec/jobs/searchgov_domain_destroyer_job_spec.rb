require 'spec_helper'

describe SearchgovDomainDestroyerJob do
  subject(:perform) { described_class.perform_now(**args) }

  let(:domain) { 'www.archive.gov' }
  let!(:searchgov_domain) {
    SearchgovDomain.create!(domain: domain, status: 200)
  }
  let(:args) {
    { searchgov_domain: searchgov_domain }
  }

  describe '#perform' do
    it 'requires a searchgov_domain as an argument' do
      expect{ described_class.perform_now }.
        to raise_error(ArgumentError, /missing keyword: :?searchgov_domain/)
    end

    it 'destroys the searchgov domain' do
      expect(searchgov_domain).to receive(:destroy!)
      perform
    end

    context 'when the searchgov_domain has associated searchgov_url records' do
      let(:url1) { 'https://www.archive.gov/info' }
      let(:url2) { 'https://www.archive.gov/hmmm' }
      let!(:searchgov_url1) { SearchgovUrl.create!(url: url1) }
      let!(:searchgov_url2) { SearchgovUrl.create!(url: url2) }

      it 'destroys the searchgov_urls' do
        expect { perform }.to change{ SearchgovUrl.count }.by(-2)
      end
    end
  end

  it_behaves_like 'a searchgov job'
end
