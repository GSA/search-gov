# frozen_string_literal: true

# Central place for holding login.gov settings. Ideally, the authlogic
# plugin would handle everything, but it doesn't. Long-term, we should
# be trying to move everythingto one place.

class LoginDotGovSettings
  def self.base_uri
    URI(Rails.application.secrets.login_dot_gov[:idp_base_url])
  end

  def self.logout_redirect_uri(id_token, login_uri)
    query = {
      id_token_hint: id_token,
      post_logout_redirect_uri: login_uri,
      state: '1234567890123456789012'
    }

    URI::HTTPS.build(
      host: base_uri.host,
      path: '/openid_connect/logout',
      query: query.to_query
    ).to_s
  end
end
