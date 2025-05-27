require 'spec_helper'

describe BulkAffiliateSearchEngineUpdateJob, type: :job do
  include ActiveJob::TestHelper

  let(:requesting_user_email) { 'test.user@example.gov' }
  let(:file_name) { 'search_engine_update.csv' }
  let(:s3_object_key) { "uploads/search_engine_update.csv" }
  let(:downloaded_temp_file_path) { "/tmp/bulk_search_engine_update_download.csv" }
  let(:job) { described_class.new }

  let(:uploader_double) { instance_double(BulkAffiliateSearchEngineUpdateUploader) }
  let(:results_double) do
    instance_double(BulkUploaderBase::Results,
                    errors?: false,
                    valid_affiliate_data: [],
                    summary_message: 'Parsed.',
                    general_errors: [],
                    error_details: [])
  end
  let(:affiliate) { instance_double(Affiliate, id: 1, errors: double('errors', full_messages: ['Something went wrong'])) }
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

    allow(Tempfile).to receive(:new).with(['bulk_search_engine_update_download.csv']).and_return(temp_file_double)

    allow(BulkAffiliateSearchEngineUpdateUploader).to receive(:new)
                                                        .with(file_name, downloaded_temp_file_path)
                                                        .and_return(uploader_double)
    allow(uploader_double).to receive(:parse_file).and_return(results_double)

    allow(BulkAffiliateSearchEngineUpdateMailer).to receive_messages(notify: mailer_double, notify_parsing_failure: mailer_double)

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

        allow(File).to receive(:exist?).with(downloaded_temp_file_path).and_return(true)
      end

      it 'raises the S3 error, attempts cleanup, and does not proceed further' do
        expect { job.perform(requesting_user_email, file_name, s3_object_key) }.to raise_error(Aws::S3::Errors::NoSuchKey)
      end
    end

    context 'when the uploader finds errors during parsing' do
      let(:general_errors) { ['CSV Malformed'] }
      let(:error_details) { [{ identifier: '123', error: 'Invalid search engine' }] }

      before do
        allow(results_double).to receive_messages(
                                   errors?: true,
                                   general_errors: general_errors,
                                   error_details: error_details
                                 )
      end

      it 'logs a warning, sends a failure email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(BulkAffiliateSearchEngineUpdateMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          general_errors,
          error_details
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when no valid affiliate data is found' do
      before do
        allow(results_double).to receive_messages(
                                   errors?: false,
                                   valid_affiliate_data: [],
                                   summary_message: 'No valid data found.'
                                 )
      end

      it 'logs a warning, sends a failure email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Rails.logger).to have_received(:warn).with(
          a_string_matching(/BulkAffiliateSearchEngineUpdateJob: Parsing failed or no valid data found.*User: #{requesting_user_email}/)
        )
        expect(BulkAffiliateSearchEngineUpdateMailer).to have_received(:notify_parsing_failure).with(
          requesting_user_email,
          file_name,
          [],
          []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when processing is successful' do
      let(:valid_affiliate_data) { [{ id: '1', search_engine: 'searchgov' }] }

      before do
        allow(results_double).to receive_messages(valid_affiliate_data: valid_affiliate_data)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate)
        allow(affiliate).to receive(:update).with(search_engine: 'searchgov').and_return(true)
      end

      it 'updates affiliates, sends a success email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Affiliate).to have_received(:find_by).with(id: 1)
        expect(affiliate).to have_received(:update).with(search_engine: 'searchgov')
        expect(BulkAffiliateSearchEngineUpdateMailer).to have_received(:notify).with(
          requesting_user_email, file_name, [{ identifier: '1', search_engine: 'searchgov' }], []
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end

    context 'when some affiliates fail to update' do
      let(:valid_affiliate_data) { [{ id: '1', search_engine: 'searchgov' }, { id: '2', search_engine: 'bing_v7' }] }
      let(:affiliate2) { instance_double(Affiliate, id: 2, errors: double('errors', full_messages: ['Validation failed'])) }

      before do
        allow(results_double).to receive_messages(valid_affiliate_data: valid_affiliate_data)
        allow(Affiliate).to receive(:find_by).with(id: 1).and_return(affiliate)
        allow(Affiliate).to receive(:find_by).with(id: 2).and_return(affiliate2)

        allow(affiliate).to receive(:update).with(search_engine: 'searchgov').and_return(true)
        allow(affiliate2).to receive(:update).with(search_engine: 'bing_v7').and_return(false)
      end

      it 'logs errors, sends a partial success email, and cleans up the downloaded file' do
        job.perform(requesting_user_email, file_name, s3_object_key)

        expect(Rails.logger).to have_received(:error).with(
          a_string_matching(/BulkAffiliateSearchEngineUpdateJob: Failed to update Affiliate 2.*Validation failed/)
        )
        expect(BulkAffiliateSearchEngineUpdateMailer).to have_received(:notify).with(
          requesting_user_email,
          file_name,
          [{ identifier: '1', search_engine: 'searchgov' }],
          [{ identifier: '2', search_engine: 'bing_v7', error: 'Update failed: Validation failed' }]
        )
        expect(mailer_double).to have_received(:deliver_later)
        expect(FileUtils).to have_received(:rm_f).with(downloaded_temp_file_path)
      end
    end
  end
end