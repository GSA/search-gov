require 'spec_helper'

describe Admin::BulkAffiliateStylesUploadController do
  fixtures :users
  let(:user) { users('affiliate_admin') }

  before do
    activate_authlogic
  end

  describe "GET 'index'" do
    context 'when not logged in' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        UserSession.create(user)
      end

      it 'allows the admin to manage superfresh urls' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #upload' do
    let(:file) { fixture_file_upload('/csv/affiliate_styles.csv', 'text/csv') }
    let(:validator_instance) { instance_double(BulkAffiliateStylesUploader::AffiliateStylesFileValidator) }
    let(:upload) do
      post :upload, params: { bulk_upload_affiliate_styles: file }
    end

    before do
      UserSession.create(user)
      allow(BulkAffiliateStylesUploader::AffiliateStylesFileValidator).to receive(:new).and_return(validator_instance)
    end

    context 'when the upload is successful' do
      before do
        allow(validator_instance).to receive(:validate!).and_return(true)
        allow(BulkAffiliateStylesUploaderJob).to receive(:perform_now)
      end

      it 'enqueues the job' do
        upload
        uploaded_file = assigns(:file)

        expect(BulkAffiliateStylesUploaderJob).to have_received(:perform_now).with(user, uploaded_file.original_filename, uploaded_file.tempfile.path)
      end

      it 'sets a success flash message' do
        upload

        expect(flash[:success]).to eq("Successfully uploaded #{file.original_filename} for processing.\nThe results will be emailed to you.\n")
      end

      it 'redirects to the index path' do
        upload

        expect(response).to redirect_to admin_bulk_affiliate_styles_upload_index_path
      end
    end

    context 'when the upload fails' do
      before do
        allow(validator_instance).to receive(:validate!).and_raise(BulkAffiliateStylesUploader::Error, 'Invalid file format')
        allow(BulkAffiliateStylesUploaderJob).to receive(:perform_now).and_raise(BulkAffiliateStylesUploader::Error, 'Upload failed')
      end

      it 'sets an error flash message' do
        upload

        expect(flash[:error]).to eq('Invalid file format')
      end

      it 'redirects to the index path' do
        upload

        expect(response).to redirect_to admin_bulk_affiliate_styles_upload_index_path
      end
    end
  end
end
