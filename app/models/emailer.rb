class Emailer < ActionMailer::Base
  default_url_options[:host] = APP_URL

  def password_reset_instructions(user)
    setup_email(user.email)

    @subject += "Password Reset Instructions"
    body(:edit_password_reset_url => edit_password_reset_url(user.perishable_token))
  end

  def new_user_to_admin(user)
    setup_email("usagov@searchsi.com")
    @subject += "New user signed up for USA Search Services"
    body(:user => user)
  end

  def welcome_to_new_user(user)
    setup_email(user.email)
    @subject += "Welcome to USA Search Services"
    body(:user => user)
  end

  private
  def setup_email(recipients)
    @recipients = recipients
    @from       = "noreply@usasearch.gov"
    @subject    = "[USASearch] "
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
  end

end
