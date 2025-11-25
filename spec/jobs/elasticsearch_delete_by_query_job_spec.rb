require 'spec_helper'

RSpec.describe ElasticsearchDeleteByQueryJob, type: :job do
  let(:index) { 'test_index' }
  let(:retention_days) { '30' }

  before do
    # Set the local environment variables
    ENV['SEARCHELASTIC_INDEX'] = index
    ENV['OPENSEARCH_SEARCH_RETENTION_DAYS'] = retention_days

    # Stub the environment variables
    allow(ENV).to receive(:fetch).with('SEARCHELASTIC_INDEX').and_return(index)
    allow(ENV).to receive(:fetch).with('OPENSEARCH_SEARCH_RETENTION_DAYS').and_return(retention_days)
    allow(ENV).to receive(:fetch).and_call_original
  end

  describe '#perform' do
    before do
      allow(Elasticsearch::Client).to receive(:new).and_return(Elasticsearch::Client.new(hosts: ['http://localhost:9200']))
    end

    context 'when retention days is valid' do
      it 'deletes documents from the Elasticsearch index' do
        expect(ES.client).to receive(:delete_by_query).with(
          index: index,
          body: {
            query: {
              range: {
                updated_at: { lt: "now-#{retention_days}d/d" }
              }
            }
          },
          slices: 'auto',
          requests_per_second: 500,
          conflicts: 'proceed',
          scroll_size: 5000,
          refresh: false,
          wait_for_completion: false,
          timeout: '30m'
        )

        ElasticsearchDeleteByQueryJob.perform_now
      end
    end

    context 'when retention days is invalid' do
      let(:retention_days) { 'abc' }

      it 'raises an ArgumentError' do
        expect { ElasticsearchDeleteByQueryJob.perform_now }.to raise_error(ArgumentError, 'OPENSEARCH_SEARCH_RETENTION_DAYS must be a positive integer')
      end
    end

    context 'when retention days is zero or negative' do
      let(:retention_days) { '0' }

      it 'raises an ArgumentError' do
        expect { ElasticsearchDeleteByQueryJob.perform_now }.to raise_error(ArgumentError, 'OPENSEARCH_SEARCH_RETENTION_DAYS must be greater than 0')
      end
    end

    context 'when SEARCHELASTIC_INDEX environment variable is missing' do
      before do
        allow(ENV).to receive(:fetch).with('SEARCHELASTIC_INDEX').and_raise(KeyError)
      end

      it 'raises a KeyError' do
        expect { ElasticsearchDeleteByQueryJob.perform_now }.to raise_error(KeyError)
      end
    end
  end
end
