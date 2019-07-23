# frozen_string_literal: true

require 'spec_helper'

RESET_PASSWORD_MESSAGE  = <<~MESSAGE.chomp.squish
    Instructions to reset your password have been
    emailed to you. Please check your email.
MESSAGE

NOT_AUTHORIZED_MESSAGE = <<~MESSAGE.chomp.squish
    These credentials are not recognized as valid for accessing Search.gov.
    Please contact search@support.digitalgov.gov if you believe this is in error.
MESSAGE

describe PasswordResetsController do
  context 'when unknown token is passed in' do
    it 'should redirect to the password reset page' do
      get :edit, id: 'fail'
      expect(response).to redirect_to(new_password_reset_path)
    end
  end

  describe '#create' do
    context 'when params[:email] is not a string' do
      before { post :create, email: { 'foo': 'bar' } }
      it { is_expected.to set_flash.now.to(/#{RESET_PASSWORD_MESSAGE}/) }
    end

    context 'when User is not approved' do
      before do
        user = mock_model User
        expect(User).to receive(:find_by_email).with('not_approved@email.gov').and_return user
        expect(user).to receive(:is_not_approved?).and_return true
        post :create, email: 'not_approved@email.gov'
      end

      it { is_expected.to set_flash[:notice].to(/#{NOT_AUTHORIZED_MESSAGE}/) }
      it { is_expected.to redirect_to(new_password_reset_path) }
    end
  end

  describe '#edit' do
    context 'when User is not approved' do
      before do
        user = mock_model User
        expect(User).to receive(:find_using_perishable_token).and_return user
        expect(user).to receive(:is_not_approved?).and_return true
        get :edit, id: 'my token'
      end

      it { is_expected.to set_flash[:notice].to(/#{NOT_AUTHORIZED_MESSAGE}/) }
      it { is_expected.to redirect_to(new_password_reset_path) }
    end
  end

  describe '#updated' do
    context 'when User is not approved' do
      before do
        user = mock_model User
        expect(User).to receive(:find_using_perishable_token).and_return user
        expect(user).to receive(:is_not_approved?).and_return true
        put :update, id: 'my token'
      end

      it { is_expected.to set_flash[:notice].to(/#{NOT_AUTHORIZED_MESSAGE}/) }
      it { is_expected.to redirect_to(new_password_reset_path) }
    end
  end
end
