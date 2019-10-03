# frozen_string_literal: true

module OmniauthHelpers
  OmniAuth.config.test_mode = true

  def mock_user_auth(email = 'test@gsa.gov', uid = '12345')
    omniauth_hash = {
      'provider': 'logindotgov',
      'uid': uid,
      'info': {
        'email': email
      }
    }

    OmniAuth.config.add_mock(:login_dot_gov, omniauth_hash)
  end
end
