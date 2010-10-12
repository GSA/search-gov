require 'spec_helper'

describe Admin::GovFormsController do
  fixtures :users
  integrate_views

  before do
    activate_authlogic
  end

  it "should require login" do
    get :new
    response.should redirect_to(new_user_session_path)
  end

  context "a logged in user" do
    before do
      @user = users(:affiliate_admin)
      UserSession.create(@user)
    end
  end
end
