# require 'rails_helper'
require 'spec_helper'

RSpec.describe SearchgovUrlsJob, type: :job do
  let(:job_id) { '12345' }
  let(:urls) { ['http://example.com', 'http://example.org'] }
  let(:time_started) { Time.zone.now }

  describe '#perform' do
    it 'sets the time started' do
      expect(Time).to receive(:zone).and_return(double(now: time_started))
      described_class.perform_now(job_id, urls)
    end

    it 'sets the total count' do
      expect { described_class.perform_now(job_id, urls) }.to change { described_class.new.total_count }.from(nil).to(2)
    end

    it 'creates a new BulkUrlUploader' do
      expect(BulkUrlUploader).to receive(:new).with(job_id, urls)
      described_class.perform_now(job_id, urls)
    end

    it 'calls upload_and_index on the BulkUrlUploader' do
      uploader = double(upload_and_index: true)
      allow(BulkUrlUploader).to receive(:new).and_return(uploader)
      expect(uploader).to receive(:upload_and_index)
      described_class.perform_now(job_id, urls)
    end

    it 'logs the results' do
      expect(Rails.logger).to receive(:info).with(/SearchgovUrlsJob/)
      described_class.perform_now(job_id, urls)
    end

    it 'logs the correct information' do
      uploader = instance_double(BulkUrlUploader, upload_and_index: true, results: double(name: 'Test Results', total_count: 10, error_count: 2, start_time: time_started, end_time: Time.zone.now))
      allow(BulkUrlUploader).to receive(:new).and_return(uploader)
      expect(Rails.logger).to receive(:info).with('SearchgovUrlsJob: Test Results', total_count: 10, errors_count: 2, start_time: time_started, end_time: Time.zone.now)
      described_class.perform_now(job_id, urls)
    end

    it 'handles an exception' do
      allow(BulkUrlUploader).to receive(:new).and_raise(StandardError, 'Test Error')
      expect(Rails.logger).to receive(:error).with('SearchgovUrlsJob: StandardError - Test Error')
      described_class.perform_now(job_id, urls)
    end
  end
end
