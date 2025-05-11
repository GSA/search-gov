require 'spec_helper'

describe Admin::BulkAffiliateDeleteController, type: :controller do
  fixtures :users
  let(:user) { users('affiliate_admin') }

  before { activate_authlogic }

  describe "GET #index" do
    context 'when not logged in' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        UserSession.create(user)
      end

      it 'renders the index template successfully' do
        get :index
        expect(response).to be_successful
        expect(response).to render_template(:index)
      end

      it 'assigns the page title' do
        get :index
        expect(assigns(:page_title)).to eq('Bulk Affiliate Delete')
      end
    end
  end

  describe 'POST #upload' do
    let(:file) { fixture_file_upload('/csv/delete_affiliates.csv', 'text/csv') }
    let(:upload_with_file) { post :upload, params: { file: file } }
    let(:upload_without_file) { post :upload, params: {} }

    context 'when not logged in' do
      it 'redirects to the login page' do
        upload_with_file
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before { UserSession.create(user) }

      context 'when no file is selected' do
        before { allow(BulkAffiliateDeleteJob).to receive(:perform_later) }

        it 'sets an error flash message' do
          upload_without_file
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_affiliate_delete.upload.no_file_selected'))
        end

        it 'redirects to the index path' do
          upload_without_file
          expect(response).to redirect_to admin_bulk_affiliate_delete_index_path
        end

        it 'does not call the BulkAffiliateDeleteJob' do
          upload_without_file
          expect(BulkAffiliateDeleteJob).not_to have_received(:perform_later)
        end
      end

      context 'when a file is provided and enqueuing the job is successful' do
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }
        let(:expected_s3_key_regex) do
          %r{^bulk-delete-uploads/\d+-[\da-fA-F]{16}-#{Regexp.escape(file.original_filename)}$}
        end

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateDeleteJob).to receive(:perform_later)
        end

        it 'calls BulkAffiliateDeleteJob.perform_later with correct arguments' do
          upload_with_file
          expect(BulkAffiliateDeleteJob).to have_received(:perform_later).with(
            user.email,
            file.original_filename,
            a_string_matching(expected_s3_key_regex)
          )
        end

        it 'sets a notice flash message' do
          upload_with_file
          expect(flash[:notice]).to include("Successfully uploaded #{file.original_filename} for processing.")
        end

        it 'redirects to the index path' do
          upload_with_file
          expect(response).to redirect_to admin_bulk_affiliate_delete_index_path
        end

        it 'attempts to upload the file to S3' do
          upload_with_file
          expect(mock_s3_client).to have_received(:put_object).with(
            bucket: S3_CREDENTIALS[:bucket], # This seems to resolve consistently in your test's context
            key: a_string_matching(expected_s3_key_regex),
            body: an_instance_of(Tempfile) # Changed from file.tempfile
          )
        end
      end

      context 'when enqueuing the job raises an error' do
        let(:error_message) { 'Something went wrong during enqueueing' }
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateDeleteJob).to receive(:perform_later).and_raise(StandardError.new(error_message))
        end

        it 'raises the StandardError' do
          expect { upload_with_file }.to raise_error(StandardError, error_message)
        end
      end
    end
  end
end
