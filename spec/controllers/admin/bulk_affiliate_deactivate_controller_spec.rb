require 'spec_helper'

describe Admin::BulkAffiliateDeactivateController, type: :controller do
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
        expect(assigns(:page_title)).to eq('Bulk Affiliate Deactivate')
      end
    end
  end

  describe 'POST #upload' do
    let(:file) { fixture_file_upload('/csv/deactivate_affiliates.csv', 'text/csv') }
    let(:upload_with_file) { post :upload, params: { file: file } }
    let(:upload_without_file) { post :upload, params: {} }

    context 'when not logged in' do
      it 'redirects to the login page' do
        upload_with_file
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        UserSession.create(user)
        allow(controller.helpers).to receive(:sanitize).with(file.original_filename).and_return(file.original_filename)
      end

      context 'when no file is selected' do
        before { allow(BulkAffiliateDeactivateJob).to receive(:perform_later) }

        it 'sets an error flash message' do
          upload_without_file
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_upload.no_file_selected', action: 'deactivation'))
        end

        it 'redirects to the index path' do
          upload_without_file
          expect(response).to redirect_to admin_bulk_affiliate_deactivate_index_path
        end

        it 'does not call the BulkAffiliateDeactivateJob' do
          upload_without_file
          expect(BulkAffiliateDeactivateJob).not_to have_received(:perform_later)
        end
      end

      context 'when a file is provided and enqueuing the job is successful' do
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }
        let(:expected_s3_key_regex) do
          %r{^bulk-deactivate-uploads/\d+-[\da-fA-F]{16}-#{Regexp.escape(file.original_filename)}$}
        end

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateDeactivateJob).to receive(:perform_later)
        end

        it 'calls BulkAffiliateDeactivateJob.perform_later with correct arguments' do
          upload_with_file
          expect(BulkAffiliateDeactivateJob).to have_received(:perform_later).with(
            user.email,
            file.original_filename,
            a_string_matching(expected_s3_key_regex)
          )
        end

        it 'redirects to the index path' do
          upload_with_file
          expect(response).to redirect_to admin_bulk_affiliate_deactivate_index_path
        end
      end

      context 'when enqueuing the job raises an error' do
        let(:error_message) { 'Something went wrong during enqueueing for deactivation' }
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateDeactivateJob).to receive(:perform_later).and_raise(StandardError.new(error_message))
        end

        it 'raises the StandardError' do
          expect { upload_with_file }.to raise_error(StandardError, error_message)
        end
      end
    end
  end
end
