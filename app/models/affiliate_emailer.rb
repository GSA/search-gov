class AffiliateEmailer < ActionMailer::Base
  default_url_options[:host] = APP_URL

  def email(affiliate_user, subject, body)
    @recipients = affiliate_user.email
    @from = APP_EMAIL_ADDRESS
    @subject = subject
    @sent_on = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
    affiliate_ids = affiliate_user.affiliates.collect{|a| a.name}
    @body_text = body
    @name = affiliate_user.contact_name
    @affiliate_ids = affiliate_ids
    @email = affiliate_user.email
  end

end
