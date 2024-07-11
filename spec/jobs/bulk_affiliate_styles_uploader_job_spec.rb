require 'spec_helper'

RSpec.describe BulkAffiliateStylesUploaderJob do
  fixtures :users
  let(:job_instance) { described_class.new }
  let(:user) { users('affiliate_admin') }
  let(:file) { fixture_file_upload('/csv/affiliate_styles.csv', 'text/csv') }
  let(:filename) { 'affiliate_styles.csv' }
  let(:filepath) { file.tempfile.path }
  let(:results) { 'results' }
  let(:uploader) { instance_double(BulkAffiliateStylesUploader, upload: true, results: uploader_results) }
  let(:uploader_results) { instance_double(results, file_name: filename, total_count: 100, error_count: 2) }
  let(:mailer_instance) { instance_double(ActionMailer::MessageDelivery) }

  before do
    allow(BulkAffiliateStylesUploader).to receive(:new).and_return(uploader)
    allow(BulkAffiliateStylesUploadResultsMailer).to receive(:with).with(user:, results: uploader_results).and_return(BulkAffiliateStylesUploadResultsMailer)
    allow(BulkAffiliateStylesUploadResultsMailer).to receive(:results_email).and_return(mailer_instance)
    allow(mailer_instance).to receive(:deliver_now!)
    allow(Rails.logger).to receive(:info)
    # allow(job_instance).to receive(:report_results)
  end

  describe '#perform' do
    it 'calls report_results' do
      allow(job_instance).to receive(:report_results)
      job_instance.perform(user, filename, filepath)
      expect(job_instance).to have_received(:report_results)
    end
  end

  describe '#report_results' do
    before do
      job_instance.instance_variable_set(:@uploader, uploader)
      job_instance.instance_variable_set(:@user, user)
      job_instance.instance_variable_set(:@filename, filename)
    end

    it 'calls log_results and send_results_email' do
      allow(job_instance).to receive(:log_results)
      allow(job_instance).to receive(:send_results_email)
      job_instance.report_results
      expect(job_instance).to have_received(:log_results)
      expect(job_instance).to have_received(:send_results_email)
    end
  end

  describe '#log_results' do
    before do
      job_instance.instance_variable_set(:@uploader, uploader)
    end

    it 'logs the results' do
      job_instance.log_results
      expect(Rails.logger).to have_received(:info).with("BulkAffiliateStylesUploaderJob: #{filename}")
      expect(Rails.logger).to have_received(:info).with('    100 affiliates')
      expect(Rails.logger).to have_received(:info).with('    2 errors')
    end
  end

  describe '#send_results_email' do
    before do
      job_instance.instance_variable_set(:@uploader, uploader)
      job_instance.instance_variable_set(:@user, user)
    end

    it 'sends the results email' do
      job_instance.send_results_email
      expect(mailer_instance).to have_received(:deliver_now!)
    end
  end
end
