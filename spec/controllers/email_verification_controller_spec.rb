require 'spec_helper'

describe EmailVerificationController do
  fixtures :users
  before do
    activate_authlogic
  end

  describe "do GET on #show" do
    it "should require login" do
      get :show, :id=>"my token"
      response.should redirect_to(login_path)
    end

    context "when logged in and uses valid email_verification_token" do
      before do
        @user = users(:affiliate_manager_with_pending_email_verification_status)
        UserSession.create(@user)
        get :show, :id => 'my token'
      end

      it "assigns @user" do
        assigns[:user].should == @user
      end

      it "assigns flash[:notice]" do
        flash[:notice].should =~ /Thank you/
      end

      it "sends html_safe on flash[:notice]" do
        flash[:notice].should be_html_safe
      end

      it "redirects to affiliates landing page" do
        response.should redirect_to(account_path)
      end
    end

    context "when logged in and uses invalid email verification token" do
      before do
        @user = users(:affiliate_manager_with_pending_email_verification_status)
        UserSession.create(@user)
        get :show, :id => 'invalid token'
      end

      it "assigns @user" do
        assigns[:user].should == @user
      end

      it "assigns flash[:notice]" do
        flash[:notice].should =~ /^Sorry/
      end

      it "redirects to affiliates landing page" do
        response.should redirect_to(account_path)
      end
    end
  end
end