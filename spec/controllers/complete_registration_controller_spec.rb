require 'spec_helper'

describe CompleteRegistrationController do
  fixtures :users
  let(:success_message) { 'You have successfully completed your account registration.' }
  let(:failure_message) do
    'Sorry! Your request to complete registration is invalid. Are you sure you copied the right link from your email?'
  end

  describe 'do GET on #edit' do
    pending 'when unknown token is passed in' do
      before { get :edit, params: { id: 'unknown' } }
      specify { expect(response).to redirect_to(login_path) }

      it { is_expected.to set_flash[:notice].to(failure_message) }
    end
  end

  describe "do POST on #update" do
    pending "when unknown token is passed in" do
      before { post :update, params: { id: 'unknown' } }
      specify { expect(response).to redirect_to(login_path) }

      it { is_expected.to set_flash[:notice].to(failure_message) }
    end

    pending "when the form parameters are valid" do
      before do
        expect(user).to receive(:complete_registration).and_return(true)
        post :update, params: { id: 'known' }
      end

      it { is_expected.to set_flash[:success].to(success_message) }

      specify { expect(response).to redirect_to(sites_path) }
    end

    pending "when the form parameters are invalid" do
      before do
        expect(user).to receive(:complete_registration).and_return(false)
        post :update, params: { id: 'known' }
      end

      it "flash[:success] should be blank" do
        expect(flash[:success]).to be_blank
      end

      specify { expect(response).to render_template(:edit) }
    end
  end


end
