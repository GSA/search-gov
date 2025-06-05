require 'spec_helper'

describe Admin::BulkAffiliateAddController, type: :controller do
  fixtures :users
  let(:user) { users('affiliate_admin') }
  let(:file) { fixture_file_upload('/csv/add_affiliates.csv', 'text/csv') }
  let(:user_email) { 'test.user@example.com' }
  let(:upload_with_file_and_email) { post :upload, params: { file: file, email: user_email } }
  let(:upload_without_file) { post :upload, params: { email: user_email } }
  let(:upload_without_email) { post :upload, params: { file: file } }

  before { activate_authlogic }

  describe "GET #index" do
    context 'when not logged in' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before { UserSession.create(user) }

      it 'renders the index template successfully' do
        get :index
        expect(response).to be_successful
        expect(response).to render_template(:index)
      end

      it 'assigns the page title' do
        get :index
        expect(assigns(:page_title)).to eq('Bulk Add User to Affiliates')
      end
    end
  end

  describe "POST #upload" do
    context 'when not logged in' do
      it 'redirects to the login page' do
        upload_with_file_and_email
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before { UserSession.create(user) }

      context 'when no file is selected' do
        it 'sets an error flash message' do
          upload_without_file
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_upload.missing_data', action: 'add'))
        end

        it 'redirects to the index path' do
          upload_without_file
          expect(response).to redirect_to admin_bulk_affiliate_add_index_path
        end
      end

      context 'when no email is provided' do
        it 'sets an error flash message' do
          upload_without_email
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_upload.missing_data', action: 'add'))
        end

        it 'redirects to the index path' do
          upload_without_email
          expect(response).to redirect_to admin_bulk_affiliate_add_index_path
        end
      end

      context 'when both a file and email are provided' do
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }
        let(:expected_s3_key_regex) do
          %r{^bulk-add-user-uploads/\d+-[\da-fA-F]{16}-#{Regexp.escape(file.original_filename)}$}
        end

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateAddJob).to receive(:perform_later)
          allow(controller.helpers).to receive(:sanitize).with(file.original_filename).and_return(file.original_filename)
        end

        it 'calls BulkAffiliateAddJob.perform_later with correct arguments' do
          upload_with_file_and_email
          expect(BulkAffiliateAddJob).to have_received(:perform_later).with(
            user.email,
            file.original_filename,
            a_string_matching(expected_s3_key_regex),
            user_email
          )
        end

        it 'sets a notice flash message' do
          upload_with_file_and_email
          expected_message = <<~SUCCESS_MESSAGE
            Successfully uploaded #{file.original_filename} for processing.
            The user affiliate addition results will be emailed to you.
          SUCCESS_MESSAGE
          expect(flash[:notice]).to eq(expected_message.strip)
        end

        it 'redirects to the index path' do
          upload_with_file_and_email
          expect(response).to redirect_to admin_bulk_affiliate_add_index_path
        end

        it 'attempts to upload the file to S3' do
          upload_with_file_and_email
          expect(mock_s3_client).to have_received(:put_object).with(
            bucket: S3_CREDENTIALS[:bucket],
            key: a_string_matching(expected_s3_key_regex),
            body: an_instance_of(Tempfile)
          )
        end
      end

      context 'when enqueuing the job raises an error' do
        let(:error_message) { 'Something went wrong during enqueueing' }
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateAddJob).to receive(:perform_later).and_raise(StandardError.new(error_message))
        end

        it 'raises the StandardError' do
          expect { upload_with_file_and_email }.to raise_error(StandardError, error_message)
        end
      end
    end
  end
end