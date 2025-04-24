require 'spec_helper'

describe BulkAffiliateDeleteJob, type: :job do
  # --- Basic Setup ---
  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'delete_test.csv' }
  let(:file_path_pn) { Rails.root.join('tmp', "test_#{file_name}") } # Original Pathname
  let(:file_path) { file_path_pn.to_s } # Use string representation consistently
  let(:job) { described_class.new }

  # --- Mocks / Doubles ---
  let(:uploader_double) { instance_double(BulkAffiliateDeleteUploader) }
  let(:results_double) {
    instance_double(BulkUploaderBase::Results,
                    errors?: false,
                    valid_affiliate_ids: [],
                    summary_message: 'Parsed.',
                    general_errors: [],
                    error_details: [])
  }
  let(:affiliate1) { instance_double(Affiliate, id: 1) }
  let(:affiliate3) { instance_double(Affiliate, id: 3) }
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery) }

  # --- Hooks ---
  before do
    # Mock the uploader instantiation and parsing
    allow(BulkAffiliateDeleteUploader).to receive(:new)
                                            .with(file_name, file_path, requesting_user_email) # Use string path
                                            .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    # Mock the mailer
    allow(BulkAffiliateDeleteMailer).to receive(:notify).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_now)

    # Mock logger
    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:warn)

    # IMPORTANT: Stub File.exist? *before* FileUtils.touch might check it
    # Use the string path for stubbing File.exist?
    allow(File).to receive(:exist?).with(file_path).and_return(true)
    # Allow other calls to File.exist? maybe triggered by internals (optional, but safer)
    allow(File).to receive(:exist?).with(anything).and_call_original unless File.respond_to?(:exist_without_mock?)


    # Mock FileUtils.rm_f using the string path
    allow(FileUtils).to receive(:rm_f).with(file_path)

    # Ensure the dummy file exists using the string path
    FileUtils.touch(file_path)
  end

  # Clean up the dummy file after each test using the string path
  after do
    FileUtils.rm_f(file_path)
  end

  # --- Test Scenarios ---

  describe '#perform' do
    context 'when the file does not exist' do
      before do
        # Override the default stub for this context using the string path
        allow(File).to receive(:exist?).with(file_path).and_return(false)
      end

      it 'logs an error and returns early' do
        # Pass the string path to the job
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:error).with(/File not found - #{Regexp.escape(file_path)}/)
        expect(BulkAffiliateDeleteUploader).not_to have_received(:new)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        # FileUtils.rm_f expectation should use string path (already set in top before block)
        expect(FileUtils).not_to have_received(:rm_f)
      end
    end

    context 'when the uploader finds errors during parsing' do
      before do
        allow(results_double).to receive_messages(errors?: true, summary_message: 'CSV Malformed', general_errors: ['CSV Malformed'], error_details: [{ row: 1, error: 'bad data' }])
        # Ensure File.exist? returns true for the ensure block check
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'logs a warning and returns early without deleting or mailing' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path

        expect(Rails.logger).to have_received(:warn).with(/Parsing failed.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: 1/)
        expect(Affiliate).not_to receive(:find_by)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        # Expect rm_f with the string path
        expect(FileUtils).to have_received(:rm_f).with(file_path)
      end
    end

    context 'when the uploader finds no valid IDs' do
      before do
        allow(results_double).to receive(:summary_message).and_return('No valid IDs found.')
        # Ensure File.exist? returns true for the ensure block check
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'logs a warning and returns early without deleting or mailing' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path

        expect(Rails.logger).to have_received(:warn).with(/no valid IDs found.*Summary: No valid IDs found/)
        expect(Affiliate).not_to receive(:find_by)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        expect(FileUtils).to have_received(:rm_f).with(file_path) # Use string path
      end
    end

    context 'when processing is successful with valid IDs' do
      let(:valid_ids) { %w[1 3] }

      before do
        allow(results_double).to receive(:valid_affiliate_ids).and_return(valid_ids)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(Affiliate).to receive(:find_by).with(id: 3).and_return(affiliate3)
        allow(affiliate1).to receive(:destroy!)
        allow(affiliate3).to receive(:destroy!)
        # Ensure File.exist? returns true for the ensure block check
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'finds and destroys the specified affiliates' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        # ... (expectations for find_by, destroy! remain the same)
        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(Affiliate).to have_received(:find_by).with(id: 3)
        expect(affiliate1).to have_received(:destroy!)
        expect(affiliate3).to have_received(:destroy!)
      end

      it 'sends a success notification email' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        # ... (expectations for notify remain the same)
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, valid_ids, []
        )
        expect(mailer_double).to have_received(:deliver_now)
      end

      it 'deletes the temporary file' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        expect(FileUtils).to have_received(:rm_f).with(file_path) # Use string path
      end
    end

    context 'when some affiliates are not found or fail to delete' do
      let(:valid_ids) { %w[1 2 3] }

      before do
        allow(results_double).to receive(:valid_affiliate_ids).and_return(valid_ids)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(Affiliate).to receive(:find_by).with(id: 2).and_return(nil)
        allow(Affiliate).to receive(:find_by).with(id: 3).and_return(affiliate3)
        allow(affiliate1).to receive(:destroy!)
        allow(affiliate3).to receive(:destroy!).and_raise(StandardError, 'DB constraint violation')
        # Ensure File.exist? returns true for the ensure block check
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'attempts to find all affiliates' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        # ... (expectations remain the same)
        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(Affiliate).to have_received(:find_by).with(id: 2)
        expect(Affiliate).to have_received(:find_by).with(id: 3)
      end

      it 'destroys found affiliates and logs errors for failures' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        # ... (expectations remain the same)
        expect(affiliate1).to have_received(:destroy!)
        expect(affiliate3).to have_received(:destroy!) # Attempted
        expect(Rails.logger).to have_received(:warn).with("BulkAffiliateDeleteJob: Affiliate 2 not found for deletion.")
        expect(Rails.logger).to have_received(:error).with("BulkAffiliateDeleteJob: Failed to delete Affiliate 3: DB constraint violation")
      end

      it 'sends a notification email with correct success and failure lists' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        # ... (expectations remain the same)
        expected_deleted = ['1']
        expected_failed = [['2', 'Not Found'], ['3', 'DB constraint violation']]
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, expected_deleted, expected_failed
        )
        expect(mailer_double).to have_received(:deliver_now)
      end

      it 'deletes the temporary file' do
        job.perform(requesting_user_email, file_name, file_path) # Use string path
        expect(FileUtils).to have_received(:rm_f).with(file_path) # Use string path
      end
    end

    context 'file cleanup in ensure block' do
      context 'when processing fails after parsing' do
        before do
          allow(results_double).to receive(:errors?).and_return(true)
          # Ensure File.exist? returns true for the ensure block check
          allow(File).to receive(:exist?).with(file_path).and_return(true)
        end

        it 'calls FileUtils.rm_f' do
          job.perform(requesting_user_email, file_name, file_path) # Use string path
          expect(FileUtils).to have_received(:rm_f).with(file_path) # Use string path
        end
      end

      context 'when deleting an affiliate fails' do
        before do
          allow(results_double).to receive_messages(errors?: false, valid_affiliate_ids: ['1'])
          allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
          allow(affiliate1).to receive(:destroy!).and_raise(StandardError, "Deletion Boom!")
          # Ensure File.exist? returns true for the ensure block check
          allow(File).to receive(:exist?).with(file_path).and_return(true)
        end

        it 'calls FileUtils.rm_f' do
          expect { job.perform(requesting_user_email, file_name, file_path) }.not_to raise_error # Use string path
          expect(FileUtils).to have_received(:rm_f).with(file_path) # Use string path
        end
      end
    end
  end
end
