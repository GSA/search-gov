require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Analytics::QueryGroupsController do
  fixtures :users

  context "when not logged in" do
    it "should redirect to the login page" do
      get :index
      response.should redirect_to(login_path)
    end
  end

  context "when logged in as a non-analyst-admin user" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("analyst").email, :password => "admin")
    end

    it "should redirect to the usasearch home page" do
      get :index
      response.should redirect_to(home_page_url)
    end
  end

  context "when logged in as an analyst admin" do
    before do
      activate_authlogic
      UserSession.create(:email=> users("marilyn").email, :password => "admin")
    end

    it "should set a value for the number of results to show per Most Popular section (i.e., 1 day, 7 day, 30 day)" do
      get :index
      response.should be_success
    end

  end
end
