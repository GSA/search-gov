require 'spec_helper'

describe Admin::BulkAffiliateSearchEngineUpdateController, type: :controller do
  fixtures :users
  let(:user) { users('affiliate_admin') }
  let(:file) { fixture_file_upload('/csv/search_engine_update.csv', 'text/csv') }

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
        expect(assigns(:page_title)).to eq('Bulk Affiliate Search Engine Update')
      end
    end
  end

  describe 'POST #upload' do
    context 'when not logged in' do
      it 'redirects to the login page' do
        post :upload, params: { file: file }
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before { UserSession.create(user) }

      context 'when no file is selected' do
        before do
          allow(BulkAffiliateSearchEngineUpdateJob).to receive(:perform_later)
          post :upload, params: {}
        end

        it 'sets an error flash message' do
          expect(flash[:error]).to eq(I18n.t('flash_messages.admin.bulk_upload.no_file_selected', action: 'search engine update'))
        end

        it 'redirects to the index path' do
          expect(response).to redirect_to admin_bulk_affiliate_search_engine_update_index_path
        end

        it 'does not call the BulkAffiliateSearchEngineUpdateJob' do
          expect(BulkAffiliateSearchEngineUpdateJob).not_to have_received(:perform_later)
        end
      end

      context 'when a valid file is provided' do
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }
        let(:expected_s3_key_regex) do
          %r{^bulk-search-engine-update-uploads/\d+-[\da-fA-F]{16}-#{Regexp.escape(file.original_filename)}$}
        end

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateSearchEngineUpdateJob).to receive(:perform_later)
          allow(controller.helpers).to receive(:sanitize).with(file.original_filename).and_return(file.original_filename)

          post :upload, params: { file: file }
        end

        it 'calls BulkAffiliateSearchEngineUpdateJob.perform_later with correct arguments' do
          expect(BulkAffiliateSearchEngineUpdateJob).to have_received(:perform_later).with(
            user.email,
            file.original_filename,
            a_string_matching(expected_s3_key_regex)
          )
        end

        it 'redirects to the index path' do
          expect(response).to redirect_to admin_bulk_affiliate_search_engine_update_index_path
        end

        it 'sets a success flash message' do
          expected_message = <<~SUCCESS_MESSAGE
            Successfully uploaded #{file.original_filename} for processing.
            The affiliate search engine update results will be emailed to you.
          SUCCESS_MESSAGE
          expect(flash[:notice]).to eq(expected_message)
        end
      end

      context 'when enqueuing the job raises an error' do
        let(:error_message) { 'Something went wrong during enqueueing for search engine update' }
        let(:mock_s3_client) { instance_double(Aws::S3::Client) }

        before do
          allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
          allow(mock_s3_client).to receive(:put_object)
          allow(BulkAffiliateSearchEngineUpdateJob).to receive(:perform_later).and_raise(StandardError.new(error_message))
        end

        it 'raises the StandardError' do
          expect { post :upload, params: { file: file } }.to raise_error(StandardError, error_message)
        end
      end
    end
  end
end