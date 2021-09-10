# frozen_string_literal: true

shared_examples_for 'a unique job' do
  context 'when enqueuing a duplicate job' do
    subject(:enqueue_duplicate) do
      described_class.perform_later('job_args')
      described_class.perform_later('job_args')
    end

    it 'does not raise an error' do
      expect { enqueue_duplicate }.not_to raise_error
    end

    it 'only enqueues the job once' do
      expect { enqueue_duplicate }.to change {
        ApplicationJob.queue_adapter.enqueued_jobs.count
      }.from(0).to(1)
    end
  end
end
