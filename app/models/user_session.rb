class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false
  consecutive_failed_logins_limit 10
  failed_login_ban_for 30.minutes
  generalize_credentials_error_messages 'These credentials are not recognized as valid for accessing Search.gov. Please contact search@support.digitalgov.gov if you believe this is in error.'
  logout_on_timeout true

  def persisted?
    false
  end
end
