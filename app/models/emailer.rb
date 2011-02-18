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
    @subject += "Welcome to the USASearch Affiliate Program"
    body(:user => user)
  end
  
  def welcome_to_new_developer(user)
    setup_email(user.email)
    @subject += "Welcome to the USASearch Program: APIs and Web Services"
    body(:user => user)
  end
  
  def mobile_feedback(email, message)
    @recipients = I18n.t(:mobile_feedback_contact_recipients)
    @from       = email
    @subject    = I18n.t(:mobile_feedback_subject)
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=iso-8859-1; format=flowed"
    charset "iso-8859-1"
    body(:message => message)
  end
  
  def new_affiliate_site(affiliate, user)
    setup_email(user.email)
    @subject += "Your new Affiliate site"
    body(:affiliate => affiliate, :user => user)
  end
  
  def new_affiliate_user(affiliate, user, current_user)
    setup_email(user.email)
    @subject += "USASearch Affiliate Program: You Were Added to #{affiliate.display_name}"
    body(:affiliate => affiliate, :user => user, :current_user => current_user)
  end
  
  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    setup_email(user.email)
    @subject += "Welcome to the USASearch Affiliate Program"
    body(:user => user, :affiliate => affiliate, :current_user => current_user)
  end
  
  private
  
  def setup_email(recipients)
    @recipients = recipients
    @from       = APP_EMAIL_ADDRESS
    @subject    = "[USASearch] "
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
  end
end
