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

    it 'logs results and sends results email' do
      job_instance.perform(user, filename, filepath)
      expect(Rails.logger).to have_received(:info).with("BulkAffiliateStylesUploaderJob: #{filename}")
      expect(Rails.logger).to have_received(:info).with('    100 affiliates')
      expect(Rails.logger).to have_received(:info).with('    2 errors')
      expect(mailer_instance).to have_received(:deliver_now!)
    end
  end
end
