require 'spec_helper'

describe PasswordResetsController do
  context "when unknown token is passed in" do
    it "should redirect to the password reset page" do
      get :edit, :id=>"fail"
      response.should redirect_to(new_password_reset_path)
    end
  end

  describe '#create' do
    context 'when params[:email] is not a string' do
      before { post :create, email: { 'foo' => 'bar' } }
      it { should set_flash.to(/No user was found with that email address/).now }
    end

    context 'when User is not approved' do
      before do
        user = mock_model User
        User.should_receive(:find_by_email).with('not_approved@email.gov').and_return user
        user.should_receive(:is_not_approved?).and_return true
        post :create, email: 'not_approved@email.gov'
      end

      it { should set_flash[:notice].to(/You are not authorized to access Search.gov./) }
      it { should redirect_to(new_password_reset_path) }
    end
  end

  describe '#edit' do
    context 'when User is not approved' do
      before do
        user = mock_model User
        User.should_receive(:find_using_perishable_token).and_return user
        user.should_receive(:is_not_approved?).and_return true
        get :edit, id: 'my token'
      end

      it { should set_flash[:notice].to(/You are not authorized to access Search.gov./) }
      it { should redirect_to(new_password_reset_path) }
    end
  end

  describe '#updated' do
    context 'when User is not approved' do
      before do
        user = mock_model User
        User.should_receive(:find_using_perishable_token).and_return user
        user.should_receive(:is_not_approved?).and_return true
        put :update, id: 'my token'
      end

      it { should set_flash[:notice].to(/You are not authorized to access Search.gov./) }
      it { should redirect_to(new_password_reset_path) }
    end
  end
end
