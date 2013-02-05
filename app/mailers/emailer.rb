class Emailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default_url_options[:host] = APP_URL
  DEVELOPERS_EMAIL = "developers@searchsi.com"

  self.default bcc: DEVELOPERS_EMAIL

  def password_reset_instructions(user, host_with_port)
    setup_email(user.email, __method__)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token, :protocol => 'https', :host => host_with_port)
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_user_to_admin(user)
    setup_email("usagov@searchsi.com", __method__)
    @user = user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_feature_adoption_to_admin
    affiliate_feature_additions_grouping = AffiliateFeatureAddition.where(["created_at >= ?", Date.yesterday.beginning_of_day]).group_by(&:affiliate_id)
    if affiliate_feature_additions_grouping.any?
      setup_email("usagov@searchsi.com", __method__)
      @affiliate_feature_additions_grouping = affiliate_feature_additions_grouping
      @subject = ERB.new(@email_template_subject).result(binding)
      mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
        format.text { render :text => ERB.new(@email_template_body).result(binding) }
      end
    end
  end

  def feature_admonishment(user, affiliates_with_unused_features)
    setup_email(user.email, __method__)
    @affiliates_with_unused_features = affiliates_with_unused_features
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_user_email_verification(user)
    setup_email(user.email, __method__)
    @user = user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_user(user)
    setup_email(user.email, __method__)
    @user = user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_developer(user)
    setup_email(user.email, __method__)
    @user = user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def mobile_feedback(email, message)
    setup_email(I18n.t(:mobile_feedback_contact_recipients), __method__)
    @from = email
    @message = message
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on, :charset => 'iso-8859-1') do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_affiliate_site(affiliate, user)
    setup_email(user.email, __method__)
    @affiliate = affiliate
    @user = user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_affiliate_user(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @affiliate = affiliate
    @user = user
    @current_user = current_user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @user = user
    @affiliate = affiliate
    @current_user = current_user
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def saucelabs_report(admin_email, sauce_labs_link)
    setup_email(admin_email, __method__)
    @sauce_labs_link = sauce_labs_link
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def objectionable_content_alert(recipient, terms)
    setup_email(recipient, __method__)
    headers['Content-Type'] = "text/html"
    @search_terms = terms
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def affiliate_header_footer_change(affiliate)
    recipients = affiliate.users.collect(&:email).join(', ')
    setup_email(recipients, __method__)
    @affiliate = affiliate
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def affiliate_yearly_report(user, year)
    setup_email(user.email, __method__)
    headers['Content-Type'] = 'text/html'
    jan1 = Date.civil(year, 1, 1)
    @report_year = year
    @affiliate_stats = {}
    user.affiliates.select([:display_name, :name]).order(:name).each do |affiliate|
      @affiliate_stats[affiliate.display_name] = DailyQueryStat.most_popular_terms(affiliate.name, jan1, jan1.end_of_year, 100)
    end
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.html { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def affiliate_monthly_report(user, report_date)
    setup_email(user.email, __method__)
    headers['Content-Type'] = 'text/html'
    @report_date = report_date
    last_month = @report_date - 1.month
    last_year = @report_date - 1.year
    @affiliate_stats = ActiveSupport::OrderedHash.new
    user.affiliates.each do |affiliate|
      stats = {}
      stats[:affiliate] = affiliate
      stats[:total_queries] = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, affiliate.name)
      stats[:total_clicks] = DailySearchModuleStat.where({:day => @report_date.beginning_of_month..@report_date.end_of_month, :affiliate_name => affiliate.name}).sum(:clicks)
      stats[:last_month_total_queries] = DailyUsageStat.monthly_totals(last_month.year, last_month.month, affiliate.name)
      stats[:last_year_total_queries] = DailyUsageStat.monthly_totals(last_year.year, last_year.month, affiliate.name)
      stats[:last_month_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_month_total_queries])
      stats[:last_year_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_year_total_queries])
      stats[:popular_queries] = DailyQueryStat.most_popular_terms(affiliate.name, @report_date.beginning_of_month, @report_date.end_of_month, 10)
      @affiliate_stats[affiliate.name] = stats
    end
    @total_stats = {:total_queries => 0, :total_clicks => 0, :last_month_total_queries => 0, :last_year_total_queries => 0}
    @affiliate_stats.each do |affiliate_name, affiliate_stats|
      @total_stats[:total_queries] += affiliate_stats[:total_queries]
      @total_stats[:total_clicks] += affiliate_stats[:total_clicks]
      @total_stats[:last_month_total_queries] += affiliate_stats[:last_month_total_queries]
      @total_stats[:last_year_total_queries] += affiliate_stats[:last_year_total_queries]
    end
    @total_stats[:last_month_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_month_total_queries])
    @total_stats[:last_year_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_year_total_queries])
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.html { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def update_external_tracking_code(affiliate, current_user, external_tracking_code)
    setup_email('***REMOVED***', __method__)
    @affiliate = affiliate
    @current_user = current_user
    @external_tracking_code = external_tracking_code
    @subject = ERB.new(@email_template_subject).result(binding)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def public_key_upload_notification(txtfile, current_user, affiliate)
    setup_email(%w{sysadmin@searchsi.com ***REMOVED***}, __method__)
    @from = current_user.email
    @affiliate = affiliate
    @current_user = current_user
    @subject = ERB.new(@email_template_subject).result(binding)
    @public_key_txt = txtfile.tempfile.read
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
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
  end

  def calculate_percent_change(current_value, previous_value)
    (previous_value != 0 ? (current_value.to_f - previous_value.to_f) / previous_value.to_f : 0) * 100
  end
end