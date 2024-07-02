require 'spec_helper'

describe Admin::BulkAffiliateStylesUploadController do
  let(:user) { users(:affiliate_admin) }
  let(:file) { fixture_file_upload('files/test_file.csv', 'text/csv') }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns @page_title' do
      get :index
      expect(assigns(:@page_title)).to eq('Bulk Affiliate Styles Upload')
    end
  end

  describe 'POST #upload' do
    context 'when the upload is successful' do
      before do
        allow(BulkAffiliateStylesUploader::AffiliateStylesFileValidator).to have_received(:new).and_return(instance_double(BulkAffiliateStylesUploader::AffiliateStylesFileValidator, validate!: true))
        allow(BulkAffiliateStylesUploaderJob).to have_received(:perform_now)
      end

      it 'enqueues the job' do
        expect(BulkAffiliateStylesUploaderJob).to have_received(:perform_now).with(user, file.original_filename, file.tempfile.path)

        post :upload, params: { bulk_upload_affiliate_styles: file }
      end

      it 'sets a success flash message' do
        post :upload, params: { bulk_upload_affiliate_styles: file }

        expect(flash[:success]).to eq("Successfully uploaded #{file.original_filename} for processing.\nThe results will be emailed to you.\n")
      end

      it 'redirects to the index path' do
        post :upload, params: { bulk_upload_affiliate_styles: file }

        expect(response).to redirect_to admin_bulk_affiliate_styles_upload_index_path
      end
    end

    context 'when the upload fails' do
      before do
        allow(BulkAffiliateStylesUploader::AffiliateStylesFileValidator).to have_received(:new).and_return(instance_double(BulkAffiliateStylesUploader::AffiliateStylesFileValidator, validate!: true))
        allow(BulkAffiliateStylesUploaderJob).to have_received(:perform_now).and_raise(BulkAffiliateStylesUploader::Error, 'Upload failed')
      end

      it 'sets an error flash message' do
        post :upload, params: { bulk_upload_affiliate_styles: file }

        expect(flash[:error]).to eq('Upload failed')
      end

      it 'redirects to the index path' do
        post :upload, params: { bulk_upload_affiliate_styles: file }

        expect(response).to redirect_to admin_bulk_affiliate_styles_upload_index_path
      end
    end
  end
end
