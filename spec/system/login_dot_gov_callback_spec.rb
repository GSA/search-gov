# frozen_string_literal: true

require 'spec_helper'

describe 'The login.gov callback page (GET auth_logindotgov_callback)' do
  include_context 'login user'

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).
      and_call_original
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).
      with(:return_to).
      and_return(explicit_destination)

    visit auth_logindotgov_callback_path
  end

  it_behaves_like 'a landing page'
end
