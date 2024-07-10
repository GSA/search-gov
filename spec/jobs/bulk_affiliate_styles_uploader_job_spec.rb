require 'spec_helper'

RSpec.describe BulkAffiliateStylesUploaderJob do
  fixtures :users
  let(:user) { users('affiliate_admin') }
  let(:file) { fixture_file_upload('/csv/affiliate_styles.csv', 'text/csv') }
  let(:filename) { 'affiliate_styles.csv' }
  let(:filepath) { file.tempfile.path }
  let(:uploader) { instance_double(BulkAffiliateStylesUploader, upload: true, results: uploader_results) }
  let(:uploader_results) { double('results', file_name: filename, total_count: 100, error_count: 2) }
  let(:mailer_instance) { instance_double(ActionMailer::MessageDelivery) }

  before do
    allow(BulkAffiliateStylesUploader).to receive(:new).and_return(uploader)
    allow(BulkAffiliateStylesUploadResultsMailer).to receive(:with).with(user:, results: uploader_results).and_return(BulkAffiliateStylesUploadResultsMailer)
    allow(BulkAffiliateStylesUploadResultsMailer).to receive(:results_email).and_return(mailer_instance)
    allow(mailer_instance).to receive(:deliver_now!)
    allow(Rails.logger).to receive(:info)
  end

  describe '#perform' do
    it 'initializes the uploader and calls upload' do
      expect(BulkAffiliateStylesUploader).to receive(:new).with(filename, filepath).and_return(uploader)
      expect(uploader).to receive(:upload)
      subject.perform(user, filename, filepath)
    end

    it 'calls report_results' do
      expect(subject).to receive(:report_results)
      subject.perform(user, filename, filepath)
    end
  end

  describe '#report_results' do
    before do
      subject.instance_variable_set(:@uploader, uploader)
      subject.instance_variable_set(:@user, user)
      subject.instance_variable_set(:@filename, filename)
    end

    it 'calls log_results and send_results_email' do
      expect(subject).to receive(:log_results)
      expect(subject).to receive(:send_results_email)
      subject.report_results
    end
  end

  describe '#log_results' do
    before do
      subject.instance_variable_set(:@uploader, uploader)
    end

    it 'logs the results' do
      expect(Rails.logger).to receive(:info).with("BulkAffiliateStylesUploaderJob: #{filename}")
      expect(Rails.logger).to receive(:info).with('    100 affiliates')
      expect(Rails.logger).to receive(:info).with('    2 errors')
      subject.log_results
    end
  end

  describe '#send_results_email' do
    before do
      subject.instance_variable_set(:@uploader, uploader)
      subject.instance_variable_set(:@user, user)
    end

    it 'sends the results email' do
      expect(BulkAffiliateStylesUploadResultsMailer).to receive(:with).with(user:, results: uploader_results).and_return(BulkAffiliateStylesUploadResultsMailer)
      expect(BulkAffiliateStylesUploadResultsMailer).to receive(:results_email).and_return(mailer_instance)
      expect(mailer_instance).to receive(:deliver_now!)
      subject.send_results_email
    end
  end
end
