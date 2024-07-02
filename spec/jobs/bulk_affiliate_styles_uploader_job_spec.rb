require 'spec_helper'

describe BulkAffiliateStylesUploaderJob do
  let(:user) { create(:user) }
  let(:filename) { 'test_file.csv' }
  let(:filepath) { Rails.root.join('spec/fixtures/files/test_file.csv') }
  let(:uploader) { instance_double(BulkAffiliateStylesUploader) }
  let(:results) { instance_double('Results', file_name: filename, total_count: 10, error_count: 2) }
  
  before do
    allow(BulkAffiliateStylesUploader).to receive(:new).with(filename, filepath).and_return(uploader)
    allow(uploader).to receive(:upload)
    allow(uploader).to receive(:results).and_return(results)
    allow(Rails.logger).to receive(:info)
  end

  describe '#perform' do
    it 'initializes the uploader and calls upload' do
      expect(BulkAffiliateStylesUploader).to receive(:new).with(filename, filepath).and_return(uploader)
      expect(uploader).to receive(:upload)

      described_class.perform_now(user, filename, filepath)
    end

    it 'calls report_results' do
      job = described_class.new
      expect(job).to receive(:report_results)

      job.perform(user, filename, filepath)
    end
  end

  describe '#log_results' do
    it 'logs the results' do
      job = described_class.new
      job.instance_variable_set(:@uploader, uploader)

      expect(Rails.logger).to receive(:info).with("BulkAffiliateStylesUploaderJob: #{filename}")
      expect(Rails.logger).to receive(:info).with("    10 affiliates")
      expect(Rails.logger).to receive(:info).with("    2 errors")

      job.log_results
    end
  end

  describe '#send_results_email' do
    it 'sends an email with the results' do
      mailer = instance_double(ActionMailer::MessageDelivery)
      allow(BulkAffiliateStylesUploadResultsMailer).to receive(:with).with(user: user, results: results).and_return(mailer)
      allow(mailer).to receive(:results_email).and_return(mailer)
      allow(mailer).to receive(:deliver_now!)

      job = described_class.new
      job.instance_variable_set(:@user, user)
      job.instance_variable_set(:@uploader, uploader)

      expect(BulkAffiliateStylesUploadResultsMailer).to receive(:with).with(user: user, results: results)
      expect(mailer).to receive(:results_email)
      expect(mailer).to receive(:deliver_now!)

      job.send_results_email
    end
  end
end
