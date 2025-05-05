require 'spec_helper'

describe BulkAffiliateDeleteJob, type: :job do
  include ActiveJob::TestHelper

  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'delete_test.csv' }
  let(:file_path_pn) { Rails.root.join('tmp', "test_#{file_name}") }
  let(:file_path) { file_path_pn.to_s }
  let(:job) { described_class.new }

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
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  before do
    FileUtils.touch(file_path)

    allow(BulkAffiliateDeleteUploader).to receive(:new)
                                            .with(file_name, file_path)
                                            .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)
    allow(BulkAffiliateDeleteMailer).to receive(:notify).and_return(mailer_double)
    allow(BulkAffiliateDeleteMailer).to receive(:notify_parsing_failure).and_return(mailer_double)

    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:warn)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(file_path).and_return(true)
    allow(FileUtils).to receive(:rm_f).with(file_path)
  end

  after do
    FileUtils.rm_f(file_path) if File.exist?(file_path)
    clear_enqueued_jobs
  end

  describe '#perform' do
    context 'when the file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'logs an error and returns early' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:error).with(/BulkAffiliateDeleteJob: File not found - #{Regexp.escape(file_path)}/)
        expect(BulkAffiliateDeleteUploader).not_to have_received(:new)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
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
                                   error_details: error_details
                                 )
      end

      it 'logs a warning, sends a failure email, and cleans up the file' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateDeleteJob: Parsing failed.*User: #{requesting_user_email}.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: 1/)
        )
        expect(Affiliate).not_to receive(:find_by)
        expect(BulkAffiliateDeleteMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          general_errors,
          error_details
        )
        expect(mailer_double).to have_received(:deliver_now)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)

        expect(FileUtils).to have_received(:rm_f).with(file_path)
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

      it 'logs a warning, sends a failure email (as processing cannot proceed), and cleans up the file' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateDeleteJob: Parsing failed or no valid IDs found.*User: #{requesting_user_email}.*Summary: No valid IDs found.*General Errors:.*Row Errors: 0/)
        )
        expect(Affiliate).not_to receive(:find_by)

        expect(BulkAffiliateDeleteMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          [],
          []
        )
        expect(mailer_double).to have_received(:deliver_now)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        expect(FileUtils).to have_received(:rm_f).with(file_path)
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
      end

      it 'finds and destroys the specified affiliates' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(Affiliate).to have_received(:find_by).with(id: 3)
        expect(affiliate1).to have_received(:destroy!)
        expect(affiliate3).to have_received(:destroy!)
      end

      it 'sends a success notification email' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, valid_ids, []
        )
        expect(mailer_double).to have_received(:deliver_now)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify_parsing_failure)
      end

      it 'deletes the temporary file' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(FileUtils).to have_received(:rm_f).with(file_path)
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
      end

      it 'attempts to find all affiliates' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(Affiliate).to have_received(:find_by).with(id: 2)
        expect(Affiliate).to have_received(:find_by).with(id: 3)
      end

      it 'destroys found affiliates and logs errors/warnings for failures' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(affiliate1).to have_received(:destroy!)
        expect(affiliate3).to have_received(:destroy!)
        expect(Rails.logger).to have_received(:warn).with("BulkAffiliateDeleteJob: Affiliate 2 not found for deletion.")
        expect(Rails.logger).to have_received(:error).with("BulkAffiliateDeleteJob: Failed to delete Affiliate 3: DB constraint violation")
      end

      it 'sends a notification email with correct success and failure lists' do
        job.perform(requesting_user_email, file_name, file_path)
        expected_deleted = ['1']
        expected_failed = [['2', 'Not Found'], ['3', 'DB constraint violation']]
        expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(
          requesting_user_email, file_name, expected_deleted, expected_failed
        )
        expect(mailer_double).to have_received(:deliver_now)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify_parsing_failure)
      end

      it 'deletes the temporary file' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(FileUtils).to have_received(:rm_f).with(file_path)
      end
    end

    context 'file cleanup in ensure block' do
      context 'when parsing fails (tested above, confirming cleanup)' do
        before do
          allow(results_double).to receive_messages(errors?: true, general_errors: [], error_details: [])
        end

        it 'calls FileUtils.rm_f via ensure' do
          job.perform(requesting_user_email, file_name, file_path)

          expect(FileUtils).to have_received(:rm_f).with(file_path)
          expect(BulkAffiliateDeleteMailer).to have_received(:notify_parsing_failure)
        end
      end

      context 'when deleting an affiliate raises an error' do
        before do
          allow(results_double).to receive_messages(errors?: false, valid_affiliate_ids: ['1'])
          allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
          allow(affiliate1).to receive(:destroy!).and_raise(StandardError, "Deletion Boom!")
        end

        it 'calls FileUtils.rm_f via ensure even if deletion fails' do
          expect { job.perform(requesting_user_email, file_name, file_path) }.not_to raise_error
          expect(FileUtils).to have_received(:rm_f).with(file_path)
          expect(BulkAffiliateDeleteMailer).to have_received(:notify).with(requesting_user_email, file_name, [], [['1', 'Deletion Boom!']])
        end
      end

      context 'when the file does not exist initially (tested above, confirming no cleanup attempt)' do
        before do
          allow(File).to receive(:exist?).with(file_path).and_return(false)
        end

        it 'does not call FileUtils.rm_f' do
          job.perform(requesting_user_email, file_name, file_path)
          expect(FileUtils).not_to have_received(:rm_f)
        end
      end
    end
  end
end
