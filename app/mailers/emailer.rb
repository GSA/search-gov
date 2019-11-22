# frozen_string_literal: true

class Emailer < ApplicationMailer
  include ActionView::Helpers::TextHelper
  default_url_options[:host] = Rails.application.secrets.organization[:app_host]
  default_url_options[:protocol] = 'https'
  ADMIN_EMAIL_ADDRESS = Rails.application.secrets.organization[:admin_email_address]
  DELIVER_FROM_EMAIL_ADDRESS = 'no-reply@support.digitalgov.gov'
  REPLY_TO_EMAIL_ADDRESS = Rails.application.secrets.organization[:support_email_address]
  NOTIFICATION_SENDER_EMAIL_ADDRESS = 'notification@support.digitalgov.gov'

  def new_user_to_admin(user)
    @user = user
    @user_contact_name = user.contact_name.presence || user.email

    if @user.affiliates.any?
      @user_inviter_contact_name = @user.inviter.contact_name.presence ||
                                   @user.inviter.email
    end

    setup_email('usagov@search.gov', __method__)
    send_mail(:text)
  end

  def new_feature_adoption_to_admin
    affiliate_feature_additions_grouping = AffiliateFeatureAddition.where(["created_at >= ?", Date.yesterday.beginning_of_day]).group_by(&:affiliate_id)
    if affiliate_feature_additions_grouping.any?
      @affiliate_feature_additions_grouping = affiliate_feature_additions_grouping
      setup_email("usagov@search.gov", __method__)
      send_mail(:text)
    end
  end

  def user_email_verification(user)
    @email_verification_url = email_verification_url(user.email_verification_token)
    @user_contact_name = user.contact_name.presence || user.email
    @user_email = user.email
    generic_user_html_email(user, __method__)
  end

  def user_approval_removed(user)
    @user = user
    @user_contact_name = user.contact_name.presence || user.email
    setup_email("usagov@search.gov", __method__)
    send_mail(:text)
  end

  def welcome_to_new_user(user)
    @new_site_url = new_site_url
    @user_contact_name = user.contact_name.presence || user.email
    generic_user_html_email(user, __method__)
  end

  def new_affiliate_site(affiliate, user)
    @affiliate = affiliate
    @user_contact_name = user.contact_name.presence || user.email
    generic_user_text_email(user, __method__)
  end

  def new_affiliate_user(affiliate, user, current_user)
    @added_by_contact_name = current_user.contact_name.presence || current_user.email
    @added_user_contact_name = user.contact_name.presence || user.email
    @affiliate_display_name = affiliate.display_name
    @affiliate_name = affiliate.name
    @affiliate_site_url = site_url(affiliate)
    @website = affiliate.website
    generic_user_html_email(user, __method__)
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    @account_url = account_url
    @added_by_contact_name = current_user.contact_name.presence || current_user.email
    @added_user_contact_name = user.contact_name.presence || user.email
    @added_user_email = user.email
    @affiliate_display_name = affiliate.display_name
    @affiliate_site_url = site_url(affiliate)
    @complete_registration_url = site_url(affiliate)
    @website = affiliate.website
    generic_user_html_email(user, __method__)
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
      query_raw_human = RtuQueryRawHumanArray.new(affiliate.name, jan1, jan1.end_of_year, 100)
      @affiliate_stats[affiliate.display_name] = query_raw_human.top_queries
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
    @dashboard = RtuDashboard.new(membership.affiliate, Date.yesterday, membership.user.sees_filtered_totals?)
    setup_email(membership.user.email, __method__)
    send_mail(:html)
  end

  def update_external_tracking_code(affiliate, current_user, external_tracking_code)
    @affiliate = affiliate
    @current_user = current_user
    @external_tracking_code = external_tracking_code
    setup_email({
      from: NOTIFICATION_SENDER_EMAIL_ADDRESS,
      to: Rails.application.secrets.organization[:support_email_address]
    }, __method__)
    send_mail(:text)
  end

  def filtered_popular_terms_report(filtered_popular_terms)
    setup_email('usagov@search.gov', __method__)
    headers['Content-Type'] = 'text/html'
    @filtered_popular_terms = filtered_popular_terms
    send_mail(:html)
  end

  def deep_collection_notification(current_user, document_collection)
    setup_email('usagov@search.gov', __method__)
    @document_collection = document_collection
    @current_user = current_user
    send_mail(:text)
  end

  def user_sites(user, sites)
    @sites = sites
    generic_user_text_email(user, __method__)
  end

  private

  def setup_email(params, method_name)
    @sent_on = Time.now
    headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
    email_template = EmailTemplate.find_by_name(method_name)
    if email_template
      @recipients, @sender = extract_recipients_and_sender(params)
      @email_template_subject = email_template.subject
      @email_template_body = email_template.body
    else
      @recipients = ADMIN_EMAIL_ADDRESS
      @email_template_subject = '[Search.gov] Missing Email template'
      @email_template_body = "Someone tried to send an email via the #{method_name} method, but we don't have a template for that method.  Please create one.  Thanks!"
    end
    @subject = ERB.new(@email_template_subject).result(binding)
  end

  def extract_recipients_and_sender(params)
    case params
      when Hash
        [params[:to], params[:from]]
      else
        [params, nil]
    end
  end

  def send_mail(format_method)
    email_headers = { to: @recipients, subject: @subject, date: @sent_on }
    if @sender.present?
      email_headers[:from] = @sender
      email_headers[:reply_to] = nil
    end

    mail email_headers do |format|
      format.send(format_method) { ERB.new(@email_template_body).result(binding) }
    end
  end

  def generic_user_text_email(user, method)
    @user = user
    setup_email(user.email, method)
    send_mail(:text)
  end

  def generic_user_html_email(user, method)
    @user = user
    setup_email(user.email, method)
    send_mail(:html)
  end
end
