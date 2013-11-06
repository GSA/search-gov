class Emailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default_url_options[:host] = APP_URL
  DEVELOPERS_EMAIL = "usasearchoutbound@searchsi.com"

  self.default bcc: DEVELOPERS_EMAIL

  def password_reset_instructions(user, host_with_port)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token, :protocol => 'https', :host => host_with_port)
    setup_email(user.email, __method__)
    send_mail(:text)
  end

  def new_user_to_admin(user)
    @user = user
    setup_email("usagov@searchsi.com", __method__)
    send_mail(:text)
  end

  def new_feature_adoption_to_admin
    affiliate_feature_additions_grouping = AffiliateFeatureAddition.where(["created_at >= ?", Date.yesterday.beginning_of_day]).group_by(&:affiliate_id)
    if affiliate_feature_additions_grouping.any?
      @affiliate_feature_additions_grouping = affiliate_feature_additions_grouping
      setup_email("usagov@searchsi.com", __method__)
      send_mail(:text)
    end
  end

  def feature_admonishment(user, affiliates_with_unused_features)
    @affiliates_with_unused_features = affiliates_with_unused_features
    setup_email(user.email, __method__)
    send_mail(:text)
  end

  def new_user_email_verification(user)
    generic_user_text_email(user, __method__)
  end

  def welcome_to_new_user(user)
    generic_user_text_email(user, __method__)
  end

  def new_affiliate_site(affiliate, user)
    @affiliate = affiliate
    generic_user_text_email(user, __method__)
  end

  def new_affiliate_user(affiliate, user, current_user)
    @affiliate = affiliate
    @current_user = current_user
    generic_user_text_email(user, __method__)
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    @affiliate = affiliate
    @current_user = current_user
    generic_user_text_email(user, __method__)
  end

  def affiliate_header_footer_change(affiliate)
    recipients = affiliate.users.collect(&:email).join(', ')
    @affiliate = affiliate
    setup_email(recipients, __method__)
    send_mail(:text)
  end

  def affiliate_yearly_report(user, year)
    headers['Content-Type'] = 'text/html'
    jan1 = Date.civil(year, 1, 1)
    @report_year = year
    @affiliate_stats = {}
    user.affiliates.select([:display_name, :name]).order(:name).each do |affiliate|
      @affiliate_stats[affiliate.display_name] = DailyQueryStat.most_popular_terms(affiliate.name, jan1, jan1.end_of_year, 100)
    end
    setup_email(user.email, __method__)
    send_mail(:html)
  end

  def affiliate_monthly_report(user, report_date)
    headers['Content-Type'] = 'text/html'
    @user_monthly_report = UserMonthlyReport.new(user, report_date)
    setup_email(user.email, __method__)
    send_mail(:html)
  end

  def daily_snapshot(membership)
    @site = membership.affiliate
    headers['Content-Type'] = 'text/html'
    @dashboard = Dashboard.new(membership.affiliate, Date.yesterday)
    setup_email(membership.user.email, __method__)
    send_mail(:html)
  end

  def update_external_tracking_code(affiliate, current_user, external_tracking_code)
    @affiliate = affiliate
    @current_user = current_user
    @external_tracking_code = external_tracking_code
    setup_email('***REMOVED***', __method__)
    @from = current_user.email
    send_mail(:text)
  end

  def filtered_popular_terms_report(filtered_popular_terms)
    setup_email('usagov@searchsi.com', __method__)
    headers['Content-Type'] = 'text/html'
    @filtered_popular_terms = filtered_popular_terms
    send_mail(:html)
  end

  def public_key_upload_notification(public_key_txt, current_user, affiliate)
    setup_email(%w{sysadmin@searchsi.com ***REMOVED***}, __method__)
    @from = current_user.email
    @affiliate = affiliate
    @current_user = current_user
    @public_key_txt = public_key_txt
    send_mail(:text)
  end

  def deep_collection_notification(current_user, document_collection)
    setup_email('usagov@searchsi.com', __method__)
    @document_collection = document_collection
    @current_user = current_user
    send_mail(:text)
  end

  private

  def setup_email(recipients, method_name)
    @from = APP_EMAIL_ADDRESS
    @sent_on = Time.now
    headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
    email_template = EmailTemplate.find_by_name(method_name)
    if email_template
      @recipients = recipients
      @email_template_subject = email_template.subject
      @email_template_body = email_template.body
    else
      @recipients = DEVELOPERS_EMAIL
      @email_template_subject = '[USASearch] Missing Email template'
      @email_template_body = "Someone tried to send an email via the #{method_name} method, but we don't have a template for that method.  Please create one.  Thanks!"
    end
    @subject = ERB.new(@email_template_subject).result(binding)
  end

  def send_mail(format_method)
    mail(to: @recipients, subject: @subject, from: @from, date: @sent_on) do |format|
      format.send(format_method) { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def generic_user_text_email(user, method)
    @user = user
    setup_email(user.email, method)
    send_mail(:text)
  end

end
