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

    context 'with an acceptable number of URLs' do
      before do
        create_batch_of_urls(10_000)
      end

      it 'handles large domains without timing out', :aggregate_failures do
        perform
        expect(SearchgovDomain.exists?(searchgov_domain.id)).to be false
        expect(SearchgovUrl.where(searchgov_domain_id: searchgov_domain.id).count).to eq(0)
      end
    end

    context 'when there is errors' do
      context 'when a SearchgovUrl destruction fails' do
        let(:failing_url) { create_failing_url }

        it 'logs an error and continues' do
          perform

          error_logged = error_messages.any? do |msg|
            msg.include?("Failed to destroy URL #{failing_url.id}: destruction failed") ||
              msg.include?('Unable to delete Searchgov i14y document')
          end
          expect(error_logged).to be true
          expect(SearchgovDomain.exists?(searchgov_domain.id)).to be false
        end
      end

      context 'when SearchgovDomain destruction fails' do
        before do
          allow(searchgov_domain).to receive(:destroy!).and_raise(StandardError.new('domain destruction failed'))
        end

        it 'logs an error and raises an exception' do
          expect { perform }.to raise_error(StandardError)

          logged_message = error_messages.find { |msg| msg.include?('Failed to destroy SearchgovDomain') && msg.include?(searchgov_domain.id.to_s) && msg.include?('domain destruction failed') }
          expect(logged_message).to eq("Failed to destroy SearchgovDomain #{searchgov_domain.id}: domain destruction failed")
        end
      end
    end
  end

  it_behaves_like 'a searchgov job'

  def create_batch_of_urls(count)
    count.times do |n|
      searchgov_domain.searchgov_urls.create(url: "https://www.archive.gov/page#{n}", hashed_url: "hash#{n}")
    end
  end

  def create_failing_url
    searchgov_domain.searchgov_urls.create(url: 'https://www.archive.gov/fail', hashed_url: 'failhash').tap do |url|
      allow(url).to receive(:destroy!).and_raise(StandardError.new('destruction failed'))
    end
  end
end
