require 'spec_helper'

describe EmailVerificationController do
  fixtures :users
  before do
    activate_authlogic
  end

  describe "do GET on #show" do
    let(:user) { users(:affiliate_manager_with_pending_email_verification_status) }
    it "should require login" do
      get :show, :id=>"my token"
      response.should redirect_to(login_path)
    end

    context "when logged in and uses valid email_verification_token" do
      before do
        UserSession.create(user)
        User.should_receive(:find_by_id).and_return(user)
        user.should_receive(:verify_email).with('my token').and_return(true)
        get :show, :id => 'my token'
      end

      it { should assign_to(:user).with(user) }
      it { should set_the_flash[:notice].to(/Thank you/) }
      it { should redirect_to(account_path) }

      it "sends html_safe on flash[:notice]" do
        flash[:notice].should be_html_safe
      end
    end

    context "when logged in and uses invalid email verification token" do
      before do
        UserSession.create(user)
        User.should_receive(:find_by_id).and_return(user)
        user.should_receive(:verify_email).with('my token').and_return(false)
        get :show, :id => 'my token'
      end

      it { should assign_to(:user).with(user) }
      it { should set_the_flash[:notice].to(/Sorry/) }
      it { should redirect_to(account_path) }
    end
  end
end
