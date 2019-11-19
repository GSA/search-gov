# frozen_string_literal: true

require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { is_expected.to use_before_action(:reset_session) }

  describe '#security_notification' do
    context 'when a user is not logged in' do
      before { get :security_notification }

      it { is_expected.to render_template(:security_notification) }
    end

    context 'when a user is already logged in' do
      before { activate_authlogic }

      include_context 'approved user logged in'

      before { get :security_notification }

      it { is_expected.to redirect_to(account_path) }
    end
  end
end
