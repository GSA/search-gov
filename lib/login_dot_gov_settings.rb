# frozen_string_literal: true

# Central place for holding login.gov settings. Ideally, the authlogic
# plugin would handle everything, but it doesn't. Long-term, we should
# be trying to move everything to one place.

class LoginDotGovSettings
  # login.gov requires us to specify a 'state' parameter for some API
  # calls, which it then passes back to us in the response. We make no
  # use of that whatsoever, so here's a constant value that we always
  # use when making such API calls.
  UNUSED_STATE_DATA  = '1234567890123456789012'
  LOGIN_IDP_BASE_URL = ENV['LOGIN_IDP_BASE_URL'] || Rails.application.secrets.login_dot_gov[:idp_base_url]
  LOGIN_CLIENT_ID    = ENV['LOGIN_CLIENT_ID']    || Rails.application.secrets.login_dot_gov[:client_id]
  HOST               = URI(LOGIN_IDP_BASE_URL).host

  def self.logout_redirect_uri(login_uri)
    query = {
      client_id: LOGIN_CLIENT_ID,
      post_logout_redirect_uri: login_uri,
      state: UNUSED_STATE_DATA
    }

    URI::HTTPS.build(
      host: HOST,
      path: '/openid_connect/logout',
      query: query.to_query
    ).to_s
  end
end
