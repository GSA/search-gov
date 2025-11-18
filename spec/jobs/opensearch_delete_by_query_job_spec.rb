# spec/jobs/opensearch_delete_by_query_job_spec.rb
require 'spec_helper'

RSpec.describe OpensearchDeleteByQueryJob, type: :job do
  let(:index) { 'test_index' }
  let(:retention_days) { '30' }

  before do
    # Set environment variables used by the job
    ENV['OPENSEARCH_SEARCH_INDEX'] = index
    ENV['OPENSEARCH_SEARCH_RETENTION_DAYS'] = retention_days

    # Stub specific ENV.fetch calls the job uses, let other fetches behave normally
    allow(ENV).to receive(:fetch).with('OPENSEARCH_SEARCH_INDEX').and_return(index)
    allow(ENV).to receive(:fetch).with('OPENSEARCH_SEARCH_RETENTION_DAYS').and_return(retention_days)
    allow(ENV).to receive(:fetch).and_call_original
  end

  describe '#perform' do
    let(:expected_body) do
      {
        query: {
          range: {
            updated_at: { lt: "now-#{retention_days}d/d" }
          }
        }
      }
    end

    context 'when retention days is valid and delete_by_query starts async' do
      it 'starts an async delete_by_query with the expected options and then waits for completion' do
        task_response = { 'task' => 'abc-123' }

        client = double('opensearch_client')
        # We only assert the initial call here — avoid hitting the real polling loop by stubbing the wait helper
        expect(client).to receive(:delete_by_query).with(
          hash_including(
            index: index,
            body: expected_body,
            slices: 'auto',
            requests_per_second: OpensearchDeleteByQueryJob::DEFAULT_REQUESTS_PER_SECOND,
            scroll_size: OpensearchDeleteByQueryJob::DEFAULT_SCROLL_SIZE,
            conflicts: 'proceed',
            refresh: false,
            wait_for_completion: false,
            timeout: '30m'
          )
        ).and_return(task_response)

        stub_const('OPENSEARCH_CLIENT', client)

        # Prevent the actual polling loop from sleeping and hitting the client; return a completed result
        allow_any_instance_of(OpensearchDeleteByQueryJob).to receive(:wait_for_task_completion)
          .with('abc-123', OpensearchDeleteByQueryJob::DEFAULT_MAX_TASK_WAIT_SECONDS)
          .and_return({ completed: true, deleted: 7 })

        expect { OpensearchDeleteByQueryJob.perform_now }.not_to raise_error
      end
    end

    context 'when delete_by_query completes synchronously' do
      it 'does not poll tasks and completes' do
        client = double('opensearch_client')
        tasks_double = double('tasks')
        allow(client).to receive(:tasks).and_return(tasks_double)

        expect(client).to receive(:delete_by_query).with(
          hash_including(index: index, body: expected_body)
        ).and_return({ 'deleted' => 3 })

        # Ensure we do not attempt to poll task status
        expect(tasks_double).not_to receive(:get)

        stub_const('OPENSEARCH_CLIENT', client)

        expect { OpensearchDeleteByQueryJob.perform_now }.not_to raise_error
      end
    end

    context 'when retention days is invalid (non-integer)' do
      let(:retention_days) { 'abc' }

      it 'raises an ArgumentError' do
        expect { OpensearchDeleteByQueryJob.perform_now }.to raise_error(
          ArgumentError,
          'OPENSEARCH_SEARCH_RETENTION_DAYS must be a positive integer'
        )
      end
    end

    context 'when retention days is zero or negative' do
      let(:retention_days) { '0' }

      it 'raises an ArgumentError' do
        expect { OpensearchDeleteByQueryJob.perform_now }.to raise_error(
          ArgumentError,
          'OPENSEARCH_SEARCH_RETENTION_DAYS must be greater than 0'
        )
      end
    end

    context 'when OPENSEARCH_SEARCH_INDEX environment variable is missing' do
      before do
        allow(ENV).to receive(:fetch).with('OPENSEARCH_SEARCH_INDEX').and_raise(KeyError)
      end

      it 'raises a KeyError' do
        expect { OpensearchDeleteByQueryJob.perform_now }.to raise_error(KeyError)
      end
    end
  end
end
