class Emailer < ActionMailer::Base
  default_url_options[:host] = APP_URL

  def password_reset_instructions(user)
    setup_email(user.email)

    @subject += "Password Reset Instructions"
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
  end

  def new_user_to_admin(user)
    setup_email("usagov@searchsi.com")
    @subject += "New user signed up for USA Search Services"
    @user = user
  end

  def new_user_email_verification(user)
    setup_email(user.email)
    @subject += 'Email Verification'
    @user = user
  end

  def welcome_to_new_user(user)
    setup_email(user.email)
    @subject += "Welcome to the USASearch Affiliate Program"
    @user = user
  end

  def welcome_to_new_developer(user)
    setup_email(user.email)
    @subject += "Welcome to the USASearch Program: APIs and Web Services"
    @user = user
  end

  def mobile_feedback(email, message)
    @recipients = I18n.t(:mobile_feedback_contact_recipients)
    @from       = email
    @subject    = I18n.t(:mobile_feedback_subject)
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=iso-8859-1; format=flowed"
    charset "iso-8859-1"
    @message = message
  end

  def new_affiliate_site(affiliate, user)
    setup_email(user.email)
    @subject += "Your new Affiliate site"
    @affiliate = affiliate
    @user = user
  end

  def new_affiliate_user(affiliate, user, current_user)
    setup_email(user.email)
    @subject += "USASearch Affiliate Program: You Were Added to #{affiliate.display_name}"
    @affiliate = affiliate
    @user = user
    @current_user = current_user
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    setup_email(user.email)
    @subject += "Welcome to the USASearch Affiliate Program"
    @user = user
    @affiliate = affiliate
    @current_user = current_user
  end

  def saucelabs_report(admin_email, sauce_labs_link)
    setup_email(admin_email)
    @subject += "Sauce Labs Report"
    @sauce_labs_link = sauce_labs_link
  end

  def objectionable_content_alert(recipient, terms)
    setup_email(recipient)
    content_type "text/html"
    @subject += "Objectionable Content Alert"
    @search_terms = terms
  end

  # For some odd reason, if this method name is changed to anything other than 'monthly_report' the attachment comes out garbled.
  # We don't know why this is, but beware.
  def monthly_report(zip_filename)
    comma_list = ReportRecipient.all.collect(&:email).join(', ')
    setup_email(comma_list)
    @subject += "Report data attached: #{File.basename(zip_filename)}"
    attachments[File.basename(zip_filename)] = File.read(zip_filename)
    mail(:to => comma_list, :subject => @subject, :from => @from)
  end
  
  def affiliate_header_footer_change(affiliate)
    recipients = affiliate.users.collect(&:email).join(', ') + ", developers@searchsi.com"
    setup_email(recipients)
    @subject += "The header and footer for #{affiliate.display_name} have been changed"
    @affiliate = affiliate
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