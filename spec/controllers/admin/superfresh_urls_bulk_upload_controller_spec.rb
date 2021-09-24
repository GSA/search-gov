require 'spec_helper'

describe Admin::SuperfreshUrlsBulkUploadController do
  fixtures :users, :affiliates, :memberships
  before do
    activate_authlogic
  end

  describe "GET 'index'" do
    context 'when not logged in' do
      it 'should redirect to the home page' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        @user = users('affiliate_admin')
        UserSession.create(@user)
      end

      it 'should allow the admin to manage superfresh urls' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe '#upload' do
    let(:file) { fixture_file_upload('/txt/superfresh_urls.txt', 'txt') }
    let(:upload) do
      post :upload, params: { superfresh_urls: file }
    end

    context 'when logged in as an admin' do
      let(:user) { users(:affiliate_admin) }

      before do
        UserSession.create(user)
      end

      context 'when an error is raised' do
        before do
          allow(SuperfreshUrl).to receive(:process_file).with(any_args).
            and_raise(StandardError.new('unable to process file'))
          upload
        end

        it { is_expected.to set_flash.to('unable to process file') }
        it { is_expected.to redirect_to admin_superfresh_urls_bulk_upload_index_path }
      end
    end
  end
end
