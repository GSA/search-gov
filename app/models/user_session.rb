class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false
  consecutive_failed_logins_limit 10
  failed_login_ban_for 30.minutes
  generalize_credentials_error_messages "Login failed due to invalid username and/or password."
  after_validation_on_create :require_password_reset

  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end

  def persisted?
    false
  end

  private

  def require_password_reset
    user = attempted_record
    if errors.empty? && user.requires_password_reset?
      user.deliver_password_reset_instructions!
      errors.add(:base, "Looks like it's time to change your password! Please check your email for the password reset message we just sent you. Thanks!")
    end
  end
end
