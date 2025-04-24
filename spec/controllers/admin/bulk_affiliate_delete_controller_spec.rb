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
      before do
        UserSession.create(user)
        allow(BulkAffiliateDeleteJob).to receive(:perform_now)
        allow(controller.logger).to receive(:error)
      end

      context 'when no file is selected' do
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
          expect(BulkAffiliateDeleteJob).not_to have_received(:perform_now)
        end
      end

      context 'when a file is provided and the job runs successfully' do
        it 'calls BulkAffiliateDeleteJob.perform_now with correct arguments' do
          upload_with_file
          uploaded_file = assigns(:file)
          expect(uploaded_file).not_to be_nil
          expect(BulkAffiliateDeleteJob).to have_received(:perform_now).with(
            user.email,
            uploaded_file.original_filename,
            uploaded_file.tempfile.path
          )
        end

        it 'sets a notice flash message' do
          upload_with_file
          expect(flash[:notice].present?).to be(true)
        end

        it 'redirects to the index path' do
          upload_with_file
          expect(response).to redirect_to admin_bulk_affiliate_delete_index_path
        end
      end

      context 'when the job raises an error' do
        let(:error_message) { 'Something went wrong during processing' }

        before do
          # Make the stubbed job raise an error
          allow(BulkAffiliateDeleteJob).to receive(:perform_now).and_raise(StandardError.new(error_message))
        end

        it 'logs the error' do
          upload_with_file
          expect(controller.logger).to have_received(:error).with(/Failed to enqueue BulkAffiliateDeleteJob: #{error_message}/)
        end

        it 'sets an error flash message indicating a queue error' do
          upload_with_file
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_affiliate_delete.upload.queue_error'))
        end

        it 'redirects to the index path' do
          upload_with_file
          expect(response).to redirect_to admin_bulk_affiliate_delete_index_path
        end
      end
    end
  end
end
