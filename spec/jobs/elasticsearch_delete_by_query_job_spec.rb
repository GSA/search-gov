require 'spec_helper'

describe ElasticsearchDeleteByQueryJob do
  subject(:perform) { described_class.perform_now }

  let(:index) { 'test_index' }
  let(:retention_days) { '30' }

  before do
    allow(ENV).to receive(:fetch).with('SEARCHELASTIC_INDEX').and_return(index)
    allow(ENV).to receive(:fetch).with('SEARCHELASTIC_RETENTION_DAYS').and_return(retention_days)
    allow(ENV).to receive(:fetch).and_call_original
  end

  it_behaves_like 'a searchgov job'

  describe 'perform' do
    context 'asynchronous deletion' do
      let(:task_id) { 'task_123' }
      let(:task_response) { { 'completed' => true, 'response' => { 'deleted' => 42 } } }

      before do
        allow(ES.client).to receive(:delete_by_query).and_return({ 'task' => task_id })
        allow(ES.client.tasks).to receive(:get).with(task_id: task_id).and_return(task_response)
        allow(ES.client.tasks).to receive(:cancel)
      end

      it 'calls delete_by_query with correct parameters' do
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

        perform
      end

      it 'waits for task completion and logs the result' do
        expect(Rails.logger).to receive(:info).with(/Async delete_by_query finished for index=#{index}: deleted=42/)

        perform
      end
    end

    context 'synchronous deletion' do
      let(:sync_response) { { 'deleted' => 10 } }

      before do
        allow(ES.client).to receive(:delete_by_query).and_return(sync_response)
      end

      it 'logs synchronous completion' do
        expect(Rails.logger).to receive(:info).with(/delete_by_query completed synchronously; deleted=10 index=#{index}/)

        perform
      end
    end

    context 'invalid retention days' do
      let(:retention_days) { 'abc' }

      it 'raises an ArgumentError' do
        expect { perform }.to raise_error(ArgumentError, 'SEARCHELASTIC_RETENTION_DAYS must be a positive integer')
      end
    end

    context 'retention days zero or negative' do
      let(:retention_days) { '0' }

      it 'raises an ArgumentError' do
        expect { perform }.to raise_error(ArgumentError, 'SEARCHELASTIC_RETENTION_DAYS must be greater than 0')
      end
    end

    context 'missing environment variables' do
      before do
        allow(ENV).to receive(:fetch).with('SEARCHELASTIC_INDEX').and_raise(KeyError)
      end

      it 'raises a KeyError' do
        expect { perform }.to raise_error(KeyError)
      end
    end
  end
end
