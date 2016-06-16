class UserSession < Authlogic::Session::Base
  allow_http_basic_auth false
  consecutive_failed_logins_limit 10
  failed_login_ban_for 30.minutes

  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
 
  def persisted?
    false
  end
end
