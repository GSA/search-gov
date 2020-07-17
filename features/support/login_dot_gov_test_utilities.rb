# frozen_string_literal: true

class LoginDotGovTestUtilities
  def self.fake_login(email: 'user@test.com', id_token: 'fake_id_token', uid: 'test_123')
    OmniAuth.config.test_mode= true
    OmniAuth.config.add_mock('logindotgov',
                             {
                               uid: uid,
                               info: { email: email },
                               credentials: { id_token: id_token },
                             }
                            )
  end
end
