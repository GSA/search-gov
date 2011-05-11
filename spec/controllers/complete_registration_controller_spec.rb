require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CompleteRegistrationController do
  fixtures :users

  describe "do GET on #edit" do
    context "when unknown token is passed in" do
      before { get :edit, :id=>"unknown" }
      specify { response.should redirect_to(login_path) }

      it "flash[:notice] should not be blank" do
        flash[:notice].should_not be_blank
      end
    end

    context "when a known token is passed in" do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }
      before do
        User.should_receive(:find_by_email_verification_token).and_return(user)
        get :edit, :id => "known"
      end

      it "@user should be assigned" do
        assigns[:user].should == user
      end
    end
  end

  describe "do POST on #update" do
    context "when unknown token is passed in" do
      before { post :update, :id=>"unknown" }
      specify { response.should redirect_to(login_path) }

      it "flash[:notice] should not be blank" do
        flash[:notice].should_not be_blank
      end
    end

    context "when a known token is passed in" do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }
      before do
        User.should_receive(:find_by_email_verification_token).and_return(user)
      end

      it "@user should be assigned" do
        post :update, :id => "known"
        assigns[:user].should == user
      end

      context "when the form parameters are valid" do
        before do
          user.should_receive(:complete_registration).and_return(true)
          post :update, :id => "known"
        end

        it "flash[:success] should not be blank" do
          flash[:success].should_not be_blank
        end

        specify { response.should redirect_to(home_affiliates_path) }
      end

      context "when the form parameters are invalid" do
        before do
          user.should_receive(:complete_registration).and_return(false)
          post :update, :id => "known"
        end

        it "flash[:success] should be blank" do
          flash[:success].should be_blank
        end

        specify { response.should render_template(:edit) }
      end
    end
  end
end
