# frozen_string_literal: true

module OmniauthHelpers
  OmniAuth.config.test_mode = true

  def mock_user_auth(email = 'test@gsa.gov',
                     uid = '12345',
                     id_token = 'mock_id_token')
    omniauth_hash = {
      'provider': 'logindotgov',
      'uid': uid,
      'info': {
        'email': email
      },
      'credentials': {
        'id_token': id_token
      },
    }

    OmniAuth.config.add_mock(:login_dot_gov, omniauth_hash)
  end
end
