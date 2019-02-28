require 'spec_helper'

describe CompleteRegistrationController do
  fixtures :users
  let(:success_message) { 'You have successfully completed your account registration.' }
  let(:failure_message) do
    'Sorry! Your request to complete registration is invalid. Are you sure you copied the right link from your email?'
  end

  describe "do GET on #edit" do
    context "when unknown token is passed in" do
      before { get :edit, :id=>"unknown" }
      specify { expect(response).to redirect_to(login_path) }

      it { is_expected.to set_flash[:notice].to(failure_message) }
    end

    context "when a known token is passed in" do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }
      before do
        expect(User).to receive(:find_by_email_verification_token).and_return(user)
        get :edit, :id => "known"
      end

      it "@user should be assigned" do
        expect(assigns[:user]).to eq(user)
      end
    end
  end

  describe "do POST on #update" do
    context "when unknown token is passed in" do
      before { post :update, :id=>"unknown" }
      specify { expect(response).to redirect_to(login_path) }

      it { is_expected.to set_flash[:notice].to(failure_message) }
    end

    context "when a known token is passed in" do
      let(:user) { users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status) }
      before do
        expect(User).to receive(:find_by_email_verification_token).and_return(user)
      end

      it '@user should be assigned' do
        post :update, { id: 'known', 'user': { 'contact_name': 'Homer Simpson' } }
        expect(assigns[:user]).to eq(user)
      end

      context "when the form parameters are valid" do
        before do
          expect(user).to receive(:complete_registration).and_return(true)
          post :update, :id => "known"
        end

        it { is_expected.to set_flash[:success].to(success_message) }

        specify { expect(response).to redirect_to(sites_path) }
      end

      context "when the form parameters are invalid" do
        before do
          expect(user).to receive(:complete_registration).and_return(false)
          post :update, :id => "known"
        end

        it "flash[:success] should be blank" do
          expect(flash[:success]).to be_blank
        end

        specify { expect(response).to render_template(:edit) }
      end
    end
  end
end
