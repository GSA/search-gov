require 'spec_helper'

describe SearchgovDomainDestroyerJob do
  subject(:perform) { described_class.perform_now(searchgov_domain) }

  let(:searchgov_domain) { SearchgovDomain.create(domain: 'www.archive.gov', status: '200 OK') }
  let(:error_messages) { [] }

  before do
    allow(Rails.logger).to receive(:error) { |message| error_messages << message }
  end

  describe '#perform' do
    it 'requires a searchgov_domain as an argument' do
      expect { described_class.perform_now }.to raise_error(ArgumentError)
    end

    it 'destroys the searchgov domain' do
      perform
      expect(SearchgovDomain.exists?(searchgov_domain.id)).to be false
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
        allow(searchgov_domain).to receive(:destroy).and_raise(RuntimeError.new('destruction failed'))
        allow(searchgov_domain).to receive(:id).and_return(999)
      end

      it 'raises an exception if domain destruction fails' do
        expect { perform }.to raise_error(RuntimeError, 'destruction failed')
      end
    end
  end

  it_behaves_like 'a searchgov job'

  def error_logged?(message)
    error_messages.any? { |msg| msg.include?(message) }
  end
end
