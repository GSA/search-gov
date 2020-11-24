# frozen_string_literal: true

describe Admin::BulkUrlUploadController do
  let(:the_controller) { subject }

  before { activate_authlogic }

  include_context 'super admin logged in' do
    describe '#upload' do
      include ActionDispatch::TestProcess::FixtureFile

      let(:user) { users(:affiliate_admin) }

      let(:original_filename) { 'good_url_file.txt' }
      let(:uploaded_file) { fixture_file_upload("txt/#{original_filename}") }
      let(:the_job_creator) { spy(BulkUrlUploadJobCreator.new(uploaded_file, user)) }

      before do
        allow(BulkUrlUploadJobCreator).to receive(:new).
                                            and_return(the_job_creator)
      end

      describe 'when the user has not selected a file' do
        let(:uploaded_file) { nil }

        before { post :upload, params: { bulk_upload_urls: uploaded_file } }

        it 'does not try to create the job' do
          expect(the_job_creator).not_to have_received(:create_job!)
        end

        it 'redirects back to the bulk upload page' do
          expect(response).to redirect_to(admin_bulk_url_upload_index_path)
        end

        it 'does not show the user a success message' do
          expect(the_controller.request.flash[:success]).to be(nil)
        end

        it 'shows the user an error message' do
          expect(the_controller.request.flash[:error]).
            to eq('Please choose a file to upload.')
        end
      end

      describe 'when the user has selected a file' do
        before { post :upload, params: { bulk_upload_urls: uploaded_file } }

        it 'tries to create the job' do
          expect(the_job_creator).to have_received(:create_job!)
        end

        it 'redirects back to the bulk upload page' do
          expect(response).to redirect_to(admin_bulk_url_upload_index_path)
        end

        it 'shows the user a success message' do
          expect(the_controller.request.flash[:success]).
            to eq("Successfully uploaded #{original_filename} for processing.")
        end

        it 'does not show the user an error message' do
          expect(the_controller.request.flash[:error]).to be(nil)
        end
      end

      describe 'when the BulkUrlUploadJobCreator throws an error' do
        let(:error_message) { 'an error message' }

        before do
          allow(the_job_creator).to receive(:create_job!).
                                      and_raise(BulkUrlUploader::Error, error_message)
          post :upload, params: { bulk_upload_urls: uploaded_file }
        end

        it 'redirects back to the bulk upload page' do
          expect(response).to redirect_to(admin_bulk_url_upload_index_path)
        end

        it 'does not show the user a success message' do
          expect(the_controller.request.flash[:success]).to be(nil)
        end

        it 'shows the user the error message' do
          expect(the_controller.request.flash[:error]).to eq(error_message)
        end
      end
    end
  end
end
