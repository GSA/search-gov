require 'spec_helper'

describe BulkAffiliateDeleteJob, type: :job do
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
  let(:mailer_double) { instance_double(ActionMailer::MessageDelivery) }

  before do
    allow(BulkAffiliateDeleteUploader).to receive(:new)
                                            .with(file_name, file_path, requesting_user_email)
                                            .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    allow(BulkAffiliateDeleteMailer).to receive(:notify).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_now)

    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:warn)

    allow(File).to receive(:exist?).with(file_path).and_return(true)
    allow(File).to receive(:exist?).with(anything).and_call_original unless File.respond_to?(:exist_without_mock?)

    allow(FileUtils).to receive(:rm_f).with(file_path)

    FileUtils.touch(file_path)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#perform' do
    context 'when the file does not exist' do
      before do
        allow(File).to receive(:exist?).with(file_path).and_return(false)
      end

      it 'logs an error and returns early' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:error).with(/File not found - #{Regexp.escape(file_path)}/)
        expect(BulkAffiliateDeleteUploader).not_to have_received(:new)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        expect(FileUtils).not_to have_received(:rm_f)
      end
    end

    context 'when the uploader finds errors during parsing' do
      before do
        allow(results_double).to receive_messages(errors?: true, summary_message: 'CSV Malformed', general_errors: ['CSV Malformed'], error_details: [{ row: 1, error: 'bad data' }])
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'logs a warning and returns early without deleting or mailing' do
        job.perform(requesting_user_email, file_name, file_path)
        expect(Rails.logger).to have_received(:warn).with(/Parsing failed.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: 1/)
        expect(Affiliate).not_to receive(:find_by)
        expect(BulkAffiliateDeleteMailer).not_to have_received(:notify)
        expect(FileUtils).to have_received(:rm_f).with(file_path)
      end
    end

    context 'when the uploader finds no valid IDs' do
      before do
        allow(results_double).to receive(:summary_message).and_return('No valid IDs found.')
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'logs a warning and returns early without deleting or mailing' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Rails.logger).to have_received(:warn).with(/no valid IDs found.*Summary: No valid IDs found/)
        expect(Affiliate).not_to receive(:find_by)
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
        allow(File).to receive(:exist?).with(file_path).and_return(true)
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
        allow(File).to receive(:exist?).with(file_path).and_return(true)
      end

      it 'attempts to find all affiliates' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(Affiliate).to have_received(:find_by).with(id: 2)
        expect(Affiliate).to have_received(:find_by).with(id: 3)
      end

      it 'destroys found affiliates and logs errors for failures' do
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
      end

      it 'deletes the temporary file' do
        job.perform(requesting_user_email, file_name, file_path)

        expect(FileUtils).to have_received(:rm_f).with(file_path)
      end
    end

    context 'file cleanup in ensure block' do
      context 'when processing fails after parsing' do
        before do
          allow(results_double).to receive(:errors?).and_return(true)
          allow(File).to receive(:exist?).with(file_path).and_return(true)
        end

        it 'calls FileUtils.rm_f' do
          job.perform(requesting_user_email, file_name, file_path)

          expect(FileUtils).to have_received(:rm_f).with(file_path)
        end
      end

      context 'when deleting an affiliate fails' do
        before do
          allow(results_double).to receive_messages(errors?: false, valid_affiliate_ids: ['1'])
          allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate1)
          allow(affiliate1).to receive(:destroy!).and_raise(StandardError, "Deletion Boom!")
          allow(File).to receive(:exist?).with(file_path).and_return(true)
        end

        it 'calls FileUtils.rm_f' do
          expect { job.perform(requesting_user_email, file_name, file_path) }.not_to raise_error
          expect(FileUtils).to have_received(:rm_f).with(file_path)
        end
      end
    end
  end
end
