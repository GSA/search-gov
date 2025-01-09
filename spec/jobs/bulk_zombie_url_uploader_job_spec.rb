# frozen_string_literal: true

describe BulkZombieUrlUploaderJob do
  let(:user) { instance_double(User, email: 'admin@example.com') }
  let(:filename) { 'bulk_zombie_urls.csv' }
  let(:filepath) { '/path/to/bulk_zombie_urls.csv' }
  let(:uploader) { instance_double(BulkZombieUrlUploader, upload: nil, results:) }
  let(:results) { instance_double(BulkZombieUrls::Results, file_name: filename, total_count: 10, error_count: 2) }

  before do
    allow(BulkZombieUrlUploader).to receive(:new).and_return(uploader)
    allow(Rails.logger).to receive(:info)
    allow(BulkZombieUrlUploadResultsMailer).to receive_message_chain(:with, :results_email, :deliver_now!)
  end

  describe '#perform' do
    it 'uploads the file and sends a results email' do
      described_class.new.perform(user, filename, filepath)

      expect(BulkZombieUrlUploader).to have_received(:new).with(filename, filepath)
      expect(uploader).to have_received(:upload)
      expect(BulkZombieUrlUploadResultsMailer).to have_received(:with).with(user:, results:)
      expect(Rails.logger).to have_received(:info).with(
        hash_including(
          BulkZombieUrlUploaderJob: filename,
          total_urls: 10,
          errors: 2
        )
      )
    end
  end
end
