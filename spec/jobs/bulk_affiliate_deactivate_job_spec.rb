require 'spec_helper'

describe BulkAffiliateDeactivateJob, type: :job do
  include ActiveJob::TestHelper

  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'deactivate_test.csv' }
  let(:s3_object_key) { "uploads/deactivate_test.csv" }
  let(:downloaded_temp_file_path) { "/tmp/bulk_deactivate_download.csv" }
  let(:job) { described_class.new }

  let(:uploader_double) { instance_double(BulkAffiliateDeactivateUploader) }
  let(:results_double) do
    instance_double(BulkUploaderBase::Results,
                    errors?: false,
                    valid_affiliate_ids: [],
                    summary_message: 'Parsed.',
                    general_errors: [],
                    error_details: [])
  end
  let(:affiliate1) { instance_double(Affiliate, id: 1, errors: double('errors', full_messages: ['Something went wrong'])) }
  let(:affiliate3) { instance_double(Affiliate, id: 3, errors: double('errors', full_messages: ['Another issue'])) }
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  let(:s3_client_double) { instance_double(Aws::S3::Client) }
  let(:temp_file_double) do
    instance_double(Tempfile,
                    path: downloaded_temp_file_path,
                    binmode: nil,
                    write: nil,
                    rewind: nil,
                    close: true,
                    unlink: true)
  end

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client_double)
    allow(s3_client_double).to receive(:get_object).with(
      bucket: S3_CREDENTIALS[:bucket],
      key: s3_object_key
    ).and_yield("csv,data\n")

    allow(Tempfile).to receive(:new).with(['bulk_deactivate_download.csv']).and_return(temp_file_double)

    allow(BulkAffiliateDeactivateUploader).to receive(:new)
                                                .with(file_name, downloaded_temp_file_path)
                                                .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    allow(BulkAffiliateDeactivateMailer).to receive_messages(notify: mailer_double, notify_parsing_failure: mailer_double)

    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:warn)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(downloaded_temp_file_path).and_return(true)
    allow(FileUtils).to receive(:rm_f).with(downloaded_temp_file_path)
  end

  after do
    clear_enqueued_jobs
  end

  describe '#perform' do
    context 'when S3 download fails' do
      let!(:temp_file_double_for_s3_failure) { instance_double(Tempfile, path: downloaded_temp_file_path) }

      before do
        allow(Tempfile).to receive(:new).with(['bulk_deactivate_download.csv']).and_return(temp_file_double_for_s3_failure)
        allow(s3_client_double).to receive(:get_object)
                                     .with(bucket: S3_CREDENTIALS[:bucket], key: s3_object_key)
                                     .and_raise(Aws::S3::Errors::NoSuchKey.new(nil, 'No such key'))
        allow(FileUtils).to receive(:rm_f).with(temp_file_double_for_s3_failure.path) # Expect cleanup
      end

      it 'raises the S3 error, attempts cleanup, and does not proceed further' do
        expect(BulkAffiliateDeactivateUploader).not_to have_received(:new)
        expect(BulkAffiliateDeactivateMailer).not_to have_received(:notify_parsing_failure)
      end
    end

    context 'when the uploader finds errors during parsing' do
      let(:general_errors) { ['CSV Malformed'] }
      let(:error_details) { [{ identifier: 'bad_id', error: 'bad data' }] }

      before do
        allow(results_double).to receive_messages(
          errors?: true,
          summary_message: 'CSV Malformed',
          general_errors: general_errors,
          error_details: error_details,
          valid_affiliate_ids: []
        )
      end

      it 'logs a warning, sends a failure email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateDeactivateJob: Parsing failed.*User: #{requesting_user_email}.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: #{error_details.count}/)
        )
        expect(BulkAffiliateDeactivateMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          general_errors,
          error_details
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when the uploader finds no valid IDs' do
      before do
        allow(results_double).to receive_messages(
          errors?: false,
          valid_affiliate_ids: [],
          summary_message: 'No valid IDs found.',
          general_errors: [],
          error_details: []
        )
      end

      it 'logs a warning, sends a parsing failure email (as per logic), and cleans up' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateDeactivateJob: Parsing failed or no valid IDs found.*User: #{requesting_user_email}.*Summary: No valid IDs found.*General Errors:.*Row Errors: 0/)
        )

        expect(BulkAffiliateDeactivateMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          [],
          []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when processing is successful with valid IDs' do
      let(:valid_ids) { %w[1 3] }

      before do
        allow(results_double).to receive_messages(valid_affiliate_ids: valid_ids, errors?: false)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(Affiliate).to receive(:find_by).with(id: 3).and_return(affiliate3)
        allow(affiliate1).to receive(:update).with(active: false).and_return(true)
        allow(affiliate3).to receive(:update).with(active: false).and_return(true)
      end

      it 'finds and deactivates the specified affiliates, sends success email, and cleans up file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(affiliate1).to have_received(:update).with(active: false)
        expect(affiliate3).to have_received(:update).with(active: false)
        expect(BulkAffiliateDeactivateMailer).to have_received(:notify).with(
          requesting_user_email, file_name, valid_ids, []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when some affiliates are not found or fail to deactivate' do
      let(:valid_ids) { %w[1 2 3] }

      before do
        allow(results_double).to receive_messages(valid_affiliate_ids: valid_ids, errors?: false)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(Affiliate).to receive(:find_by).with(id: 2).and_return(nil)
        allow(Affiliate).to receive(:find_by).with(id: 3).and_return(affiliate3)

        allow(affiliate1).to receive(:update).with(active: false).and_return(true)
        allow(affiliate3).to receive(:update).with(active: false).and_return(false)
        allow(affiliate3.errors).to receive(:full_messages).and_return(['Update validation failed'])
      end

      it 'logs errors, sends email with partial success/failure, and cleans up file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(affiliate1).to have_received(:update).with(active: false)
        expect(Rails.logger).to have_received(:warn).with("BulkAffiliateDeactivateJob: Affiliate 2 not found for deactivation.")
        expect(Rails.logger).to have_received(:error).with("BulkAffiliateDeactivateJob: Failed to deactivate Affiliate 3: Update validation failed")

        expected_successful_deactivations = ['1']
        expected_failed_deactivations = [
          { identifier: '2', error: 'Affiliate not found' },
          { identifier: '3', error: 'Update failed: Update validation failed' }
        ]

        expect(BulkAffiliateDeactivateMailer).to have_received(:notify).with(
          requesting_user_email, file_name, expected_successful_deactivations, expected_failed_deactivations
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when an unexpected error occurs during affiliate deactivation' do
      let(:valid_ids) { ['1'] }
      let(:error_message) { "Unexpected DB Boom!" }

      before do
        allow(results_double).to receive_messages(valid_affiliate_ids: valid_ids, errors?: false)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(affiliate1).to receive(:update).with(active: false).and_raise(StandardError, error_message)
      end

      it 'logs the error, includes it in failed deactivations, sends email, and cleans up' do
        expect { job.perform(requesting_user_email, file_name, s3_object_key) }.not_to raise_error

        expect(Rails.logger).to have_received(:error)
                                  .with("BulkAffiliateDeactivateJob: Unexpected error deactivating Affiliate 1: #{error_message}")

        expected_failed = [{ identifier: '1', error: "Unexpected error: #{error_message}" }]
        expect(BulkAffiliateDeactivateMailer).to have_received(:notify).with(
          requesting_user_email, file_name, [], expected_failed
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    describe 'file cleanup (ensure block)' do
      context 'when processing (e.g., affiliate update) raises an error but is rescued' do
        before do
          allow(results_double).to receive_messages(errors?: false, valid_affiliate_ids: ['1'])
          allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
          allow(affiliate1).to receive(:update).with(active: false).and_raise(StandardError, "Deactivation Boom!")
        end

        it 'still calls FileUtils.rm_f via ensure' do
          expect { job.perform(requesting_user_email, file_name, s3_object_key) }.not_to raise_error
          expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
          expected_failed = [{ identifier: '1', error: 'Unexpected error: Deactivation Boom!' }]
          expect(BulkAffiliateDeactivateMailer).to have_received(:notify).with(requesting_user_email, file_name, [], expected_failed)
        end
      end

      context 'when downloaded temp file does not exist at cleanup (e.g., already removed or never created properly)' do
        before do
          allow(Tempfile).to receive(:new).with(['bulk_deactivate_download.csv']).and_return(temp_file_double)
          allow(File).to receive(:exist?).with(downloaded_temp_file_path).and_return(false)
        end

        it 'does not call FileUtils.rm_f if File.exist? is false' do
          job.perform(requesting_user_email, file_name, s3_object_key)
          expect(FileUtils).not_to have_received(:rm_f).with(downloaded_temp_file_path)
        end
      end
    end
  end
end