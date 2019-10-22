# frozen_string_literal: true

require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { is_expected.to use_before_filter(:reset_session) }

  describe '#security_notification' do
    before { get :security_notification }

    it { is_expected.to render_template(:security_notification) }
  end
end
