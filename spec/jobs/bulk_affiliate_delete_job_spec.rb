require 'spec_helper'

describe BulkAffiliateDeleteJob, type: :job do
  include ActiveJob::TestHelper

  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'delete_test.csv' }
  let(:s3_object_key) { "uploads/delete_test.csv" }
  let(:downloaded_temp_file_path) { Rails.root.join('tmp', "downloaded_bulk_delete_#{file_name}").to_s }
  let(:job) { described_class.new }

  let(:uploader_double) { instance_double(BulkAffiliateDeleteUploader) }
  let(:results_double) do
    instance_double(BulkUploaderBase::Results,
                    errors?: false,
                    valid_affiliate_ids: [],
                    summary_message: 'Parsed.',
                    general_errors: [],
                    error_details: [])
  end
  let(:affiliate1) { instance_double(Affiliate, id: 1) }
  let(:affiliate3) { instance_double(Affiliate, id: 3) }
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

    allow(Tempfile).to receive(:new).with(['bulk_delete_download.csv']).and_return(temp_file_double)

    allow(BulkAffiliateDeleteUploader).to receive(:new)
                                            .with(file_name, downloaded_temp_file_path)
                                            .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    allow(BulkAffiliateDeleteMailer).to receive(:notify).and_return(mailer_double)
    allow(BulkAffiliateDeleteMailer).to receive(:notify_parsing_failure).and_return(mailer_double)

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
      before do
        allow(s3_client_double).to receive(:get_object)
                                     .with(bucket: S3_CREDENTIALS[:bucket], key: s3_object_key)
                                     .and_raise(Aws::S3::Errors::NoSuchKey.new(nil, 'No such key'))
      end

      it 'raises the S3 error and does not attempt cleanup if temp_file was not created' do
        expect { job.perform(requesting_user_email, file_name, s3_object_key) }.to raise_error(Aws::S3::Errors::NoSuchKey)

        expect(BulkAffiliateDeleteUploader).not_to have_received(:new)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify_parsing_failure)
        expect(FileUtils).not_to have_received(:rm_f)
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
          a_string_matching(/BulkAffiliateDeleteJob: Parsing failed.*User: #{requesting_user_email}.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: 1/)
        )
        expect(BulkAffiliateDeleteMailer).to have_received(:notify_parsing_failure).with(
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

      it 'logs a warning, sends a failure email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateDeleteJob: Parsing failed or no valid IDs found.*User: #{requesting_user_email}.*Summary: No valid IDs found.*General Errors:.*Row Errors: 0/)
        )
        expect(BulkAffiliateDeleteMailer).to have_received(:notify_parsing_failure).with(
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
        allow(affiliate1).to receive(:destroy!)
        allow(affiliate3).to receive(:destroy!)
      end

      it 'finds and destroys the specified affiliates, sends success email, and cleans up file' do
        job.perform(requesting_user_email, file_name, s3_object_key)
        expect(affiliate1).to have_received(:destroy!)
        expect(affiliate3).to have_received(:destroy!)
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, valid_ids, []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when some affiliates are not found or fail to delete' do
      let(:valid_ids) { %w[1 2 3] }

      before do
        allow(results_double).to receive_messages(valid_affiliate_ids: valid_ids, errors?: false)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
        allow(Affiliate).to receive(:find_by).with(id: 2).and_return(nil)
        allow(Affiliate).to receive(:find_by).with(id: 3).and_return(affiliate3)
        allow(affiliate1).to receive(:destroy!)
        allow(affiliate3).to receive(:destroy!).and_raise(StandardError, 'DB constraint violation')
      end

      it 'logs errors, sends email with partial success/failure, and cleans up file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(affiliate1).to have_received(:destroy!)
        expect(Rails.logger).to have_received(:warn).with("BulkAffiliateDeleteJob: Affiliate 2 not found for deletion.")
        expect(Rails.logger).to have_received(:error).with("BulkAffiliateDeleteJob: Failed to delete Affiliate 3: DB constraint violation")

        expected_deleted = ['1']
        expected_failed = [['2', 'Not Found'], ['3', 'DB constraint violation']]
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, expected_deleted, expected_failed
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'file cleanup in ensure block specific scenarios' do
      context 'when deleting an affiliate raises an error (job proceeds)' do
        before do
          allow(results_double).to receive_messages(errors?: false, valid_affiliate_ids: ['1'])
          allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
          allow(affiliate1).to receive(:destroy!).and_raise(StandardError, "Deletion Boom!")
        end

        it 'still calls FileUtils.rm_f via ensure' do
          expect { job.perform(requesting_user_email, file_name, s3_object_key) }.not_to raise_error
          expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
          expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(requesting_user_email, file_name, [], [['1', 'Deletion Boom!']])
        end
      end

      context 'when downloaded temp file does not exist at cleanup (e.g., already removed)' do
        before do
          allow(File).to receive(:exist?).with(downloaded_temp_file_path).and_return(false)
        end

        it 'does not call FileUtils.rm_f' do
          job.perform(requesting_user_email, file_name, s3_object_key)
          expect(FileUtils).not_to have_received(:rm_f).with(downloaded_temp_file_path)
        end
      end
    end
  end
end
