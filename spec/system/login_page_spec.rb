# frozen_string_literal: true

require 'spec_helper'

describe 'The login page (GET login_dot_gov)' do
  include_context 'login user'

  before do
    if explicit_destination
      visit "#{login_path}?return_to=#{explicit_destination}"
    else
      visit login_path
    end
  end

  it_behaves_like 'a landing page'
end
