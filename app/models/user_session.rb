# frozen_string_literal: true

class UserSession < Authlogic::Session::Base
  INVALID_LOGIN_MESSAGE = <<~MESSAGE.chomp
    These credentials are not recognized as valid for accessing Search.gov.
    Please contact #{Rails.application.secrets.organization[:support_email_address]} if you believe this is in error.
  MESSAGE

  allow_http_basic_auth false
  generalize_credentials_error_messages INVALID_LOGIN_MESSAGE
  logout_on_timeout true
end
