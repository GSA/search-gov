require 'spec_helper'

describe Admin::BulkAffiliateDeleteController, type: :controller do
  fixtures :users
  let(:user) { users('affiliate_admin') }

  before do
    activate_authlogic
  end

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
    let(:file) { fixture_file_upload('/csv/delete_affiliates.csv', 'text/csv')  }
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
        before { allow(BulkAffiliateDeleteJob).to receive(:perform_later) }

        it 'calls BulkAffiliateDeleteJob.perform_later with correct arguments' do
          upload_with_file
          uploaded_file = assigns(:file)
          expect(uploaded_file).not_to be_nil
          expect(BulkAffiliateDeleteJob).to have_received(:perform_later).with(
            user.email,
            uploaded_file.original_filename,
            uploaded_file.tempfile.path
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
      end

      context 'when enqueuing the job raises an error' do
        let(:error_message) { 'Something went wrong during enqueueing' }

        before do
          allow(BulkAffiliateDeleteJob).to receive(:perform_later).and_raise(StandardError.new(error_message))
        end

        it 'raises the StandardError' do
          expect { upload_with_file }.to raise_error(StandardError, error_message)
        end
      end
    end
  end
end
