# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  INVALID_LOGIN_MESSAGE = <<~MESSAGE.chomp
    These credentials are not recognized as valid for accessing Search.gov.
    Please contact search@support.digitalgov.gov if you believe this is in error.
  MESSAGE

  allow_http_basic_auth false
  consecutive_failed_logins_limit 10
  failed_login_ban_for 30.minutes
  generalize_credentials_error_messages INVALID_LOGIN_MESSAGE
  logout_on_timeout true
end
