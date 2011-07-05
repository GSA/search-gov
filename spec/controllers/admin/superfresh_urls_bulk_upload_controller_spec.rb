require 'spec/spec_helper'

describe Admin::SuperfreshUrlsBulkUploadController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end
  
  describe "GET 'index'" do
    context "when not logged in" do
      it "should redirect to the home page" do
        get :index
        response.should redirect_to login_path
      end
    end

    context "when logged in as an admin" do
      before do
        @user = users("affiliate_admin")
        UserSession.create(@user)
      end

      it "should allow the admin to manage superfresh urls" do
        get :index
        response.should be_success
      end
    end
  end
end
