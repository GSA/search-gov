require 'spec_helper'

describe Admin::SuperfreshUrlsBulkUploadController do
  fixtures :users, :affiliates, :memberships
  before do
    activate_authlogic
  end

  describe "GET 'index'" do
    context "when not logged in" do
      it "should redirect to the home page" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    context "when logged in as an admin" do
      before do
        @user = users("affiliate_admin")
        UserSession.create(@user)
      end

      it "should allow the admin to manage superfresh urls" do
        get :index
        expect(response).to be_success
      end
    end
  end

  describe '#upload' do
    context 'when logged in as an admin' do
      let(:user) { users(:affiliate_admin) }
      let(:file) { double(File, :present? => true, :content_type => 'txt') }

      before do
        UserSession.create(user)
        expect(file).to receive(:to_param).at_least(:once).and_return(file)
        expect(SuperfreshUrl).to receive(:process_file).with(file, nil, 65535).
            and_raise(Exception.new('unable to process file'))
        post :upload, :superfresh_urls => file
      end

      it { is_expected.to set_flash.to('unable to process file')}
      it { is_expected.to redirect_to admin_superfresh_urls_bulk_upload_index_path }
    end
  end
end
