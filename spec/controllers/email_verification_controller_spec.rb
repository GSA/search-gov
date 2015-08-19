require 'spec_helper'

describe EmailVerificationController do
  fixtures :users
  before do
    activate_authlogic
  end

  describe "#show" do
    subject(:attempt_email_verification) { get :show, id: token }
    let(:email) { 'verifyme@example.com' }
    let(:verifying_user) { mock_model(User, email: email) }
    let(:token) { 'verifyme' }

    before do
      User.stub(:find_by_email_verification_token).with(token).and_return(verifying_user)
    end

    context "when no user is logged in" do
      it "should set a flash message indicating they need to log in to complete verification" do
        attempt_email_verification
        flash[:notice].should eq('Please log in to complete your email verification.')
      end

      it "stores the email verification path to return to after next login" do
        attempt_email_verification
        session[:return_to].should == "/email_verification/#{token}"
      end

      it "stores the email address of the token owner in a flash" do
        attempt_email_verification
        flash[:email_to_verify].should == email
      end

      it { should redirect_to(login_path) }
    end

    context "when a user is logged in" do
      let(:user) { users(:affiliate_manager_with_pending_email_verification_status) }

      before do
        UserSession.create(user)
        User.should_receive(:find_by_id).and_return(user)
        user.should_receive(:verify_email).with(token).and_return(token_matches)
      end

      context "and the email verification token is correct for the logged in user" do
        let(:token_matches) { true }

        before do
          user.should_receive(:is_pending_approval?).and_return(needs_approval)
        end

        context "and the user does not have a pre-approved email address" do
          let(:needs_approval) { true }

          it "should set a flash message indicating they still need approval" do
            attempt_email_verification
            flash[:notice].should match(/We will be in touch with you/)
            flash[:notice].should be_html_safe
          end

          it { should redirect_to(account_path) }
        end

        context "and the user has a pre-approved email address" do
          let(:needs_approval) { false }

          it "should not set a flash message indicating they still need approval" do
            attempt_email_verification
            flash[:notice].should_not match(/We will be in touch with you/)
          end

          it { should redirect_to(account_path) }
        end
      end

      context "and the email verification token isn't correct for the logged in user" do
        let(:token_matches) { false }

        it "should set a flash message indicating they need to log in to complete verification" do
          attempt_email_verification
          flash[:notice].should eq('Please log in to complete your email verification.')
        end

        it "stores the email verification path to return to after next login" do
          attempt_email_verification
          session[:return_to].should == "/email_verification/#{token}"
        end

        it "stores the email address of the token owner in a flash" do
          attempt_email_verification
          flash[:email_to_verify].should == email
        end

        it "logs out the current user" do
          attempt_email_verification
          UserSession.find.should be_nil
        end

        it { should redirect_to(login_path) }
      end
    end
  end
end
