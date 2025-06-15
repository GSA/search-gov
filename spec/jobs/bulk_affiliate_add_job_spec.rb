require 'spec_helper'

describe BulkAffiliateAddJob, type: :job do
  include ActiveJob::TestHelper

  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'add_test.csv' }
  let(:s3_object_key) { "uploads/add_test.csv" }
  let(:email_address) { 'target.user@example.gov' }
  let(:downloaded_temp_file_path) { Rails.root.join('tmp', "downloaded_bulk_add_#{file_name}").to_s }
  let(:job) { described_class.new }

  let(:uploader_double) { instance_double(BulkAffiliateAddUploader) }
  let(:results_double) do
    instance_double(BulkUploaderBase::Results,
                    errors?: false,
                    valid_affiliate_ids: [],
                    summary_message: 'Parsed.',
                    general_errors: [],
                    error_details: [])
  end
  let(:user_double) { instance_double(User, id: 99, email: email_address) }
  let(:affiliate_double) { instance_double(Affiliate, name: 'Test Affiliate', users: double('users', exists?: false)) }
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

    allow(Tempfile).to receive(:new).with(['bulk_add_user.csv']).and_return(temp_file_double)

    allow(BulkAffiliateAddUploader).to receive(:new)
                                         .with(file_name, downloaded_temp_file_path, email_address)
                                         .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    allow(BulkAffiliateAddMailer).to receive(:notify).and_return(mailer_double)
    allow(BulkAffiliateAddMailer).to receive(:notify_parsing_failure).and_return(mailer_double)

    allow(User).to receive(:find_by_email).with(email_address).and_return(user_double)
    allow(Affiliate).to receive(:find_by_name).and_return(affiliate_double)

    allow(user_double).to receive(:add_to_affiliate)

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
        expect { job.perform(requesting_user_email, file_name, s3_object_key, email_address) }.to raise_error(Aws::S3::Errors::NoSuchKey)

        expect(BulkAffiliateAddUploader).not_to have_received(:new)
        expect(BulkAffiliateAddMailer).not_to have_received(:notify_parsing_failure)
        expect(FileUtils).not_to have_received(:rm_f)
      end
    end

    context 'when the uploader finds errors during parsing' do
      let(:general_errors) { ['CSV Malformed'] }
      let(:error_details) { [{ identifier: 'bad_affiliate', error: 'bad data' }] }

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
        job.perform(requesting_user_email, file_name, s3_object_key, email_address)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateAddJob: Parsing failed.*User: #{requesting_user_email}.*Summary: CSV Malformed.*General Errors: CSV Malformed.*Row Errors: 1/)
        )
        expect(BulkAffiliateAddMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          general_errors,
          error_details
        )
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when the user is not found' do
      let(:valid_affiliate_ids) { ['Affiliate 1'] }
      let(:error_message) { "User with email '#{email_address}' not found. No affiliates were processed." }

      before do
        allow(results_double).to receive(:valid_affiliate_ids).and_return(valid_affiliate_ids)
        allow(User).to receive(:find_by_email).with(email_address).and_return(nil)
      end

      it 'logs an error and sends a failure notification' do
        job.perform(requesting_user_email, file_name, s3_object_key, email_address)

        expect(BulkAffiliateAddMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          [error_message],
          []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(BulkAffiliateAddMailer).not_to have_received(:notify)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when processing affiliates has mixed results' do
      let(:valid_affiliate_ids) { ['Existing Site', 'Not Found Site', 'Already Member Site', 'Error Site'] }
      let(:existing_affiliate) { instance_double(Affiliate, name: 'Existing Site', users: double('users', exists?: false)) }
      let(:already_member_affiliate) { instance_double(Affiliate, name: 'Already Member Site', users: double('users', exists?: true)) }
      let(:error_affiliate) { instance_double(Affiliate, name: 'Error Site', users: double('users', exists?: false)) }

      before do
        allow(results_double).to receive(:valid_affiliate_ids).and_return(valid_affiliate_ids)

        allow(Affiliate).to receive(:find_by_name).with('Existing Site').and_return(existing_affiliate)
        allow(Affiliate).to receive(:find_by_name).with('Not Found Site').and_return(nil)
        allow(Affiliate).to receive(:find_by_name).with('Already Member Site').and_return(already_member_affiliate)
        allow(Affiliate).to receive(:find_by_name).with('Error Site').and_return(error_affiliate)

        allow(user_double).to receive(:add_to_affiliate).with(existing_affiliate, 'Bulk upload script')
        allow(user_double).to receive(:add_to_affiliate).with(error_affiliate, 'Bulk upload script').and_raise(StandardError, 'Something went wrong')
      end

      it 'correctly categorizes added and failed sites' do
        job.perform(requesting_user_email, file_name, s3_object_key, email_address)

        expect(user_double).to have_received(:add_to_affiliate).once.with(existing_affiliate, 'Bulk upload script')
        expect(Rails.logger).to have_received(:warn).with("BulkAffiliateAddJob: Affiliate Not Found Site not found.")
        expect(Rails.logger).to have_received(:error).with("BulkAffiliateAddJob: Failed to add user to Affiliate Error Site: Something went wrong")

        expect(BulkAffiliateAddMailer).to have_received(:notify).with(
          requesting_user_email,
          file_name,
          ['Existing Site'],
          a_collection_containing_exactly(
            ['Not Found Site', 'Not Found'],
            ['Already Member Site', 'User already a member.'],
            ['Error Site', 'Something went wrong']
          )
        )
      end
    end

    context 'when processing is successful' do
      let(:valid_affiliate_ids) { ['Affiliate 1', 'Affiliate 2'] }

      before do
        allow(results_double).to receive_messages(
                                   valid_affiliate_ids: valid_affiliate_ids,
                                   errors?: false
                                 )
      end

      it 'adds user to valid affiliates, sends success email, and cleans up file' do
        job.perform(requesting_user_email, file_name, s3_object_key, email_address)

        valid_affiliate_ids.each do |affiliate_name|
          expect(Affiliate).to have_received(:find_by_name).with(affiliate_name)
        end

        expect(user_double).to have_received(:add_to_affiliate).twice
        expect(BulkAffiliateAddMailer).to have_received(:notify).with(
          requesting_user_email,
          file_name,
          valid_affiliate_ids,
          []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end
  end
end