class AffiliateEmailer < ActionMailer::Base
  default_url_options[:host] = APP_URL

  def email(affiliate, subject, body, affiliate_ids)
    @recipients = affiliate.contact_email
    @from       = "***REMOVED***"
    @subject    = subject
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
    body(:body => body, :name => affiliate.contact_name, :affiliate_ids => affiliate_ids, :email => affiliate.contact_email)
  end

end
