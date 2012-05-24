class Emailer < ActionMailer::Base
  default_url_options[:host] = APP_URL
  DEVELOPERS_EMAIL = "developers@searchsi.com"

  def password_reset_instructions(user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_user_to_admin(user)
    setup_email("usagov@searchsi.com", __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_feature_adoption_to_admin
    affiliate_feature_additions_grouping = AffiliateFeatureAddition.where(["created_at >= ?", Date.yesterday.beginning_of_day]).group_by(&:affiliate_id)
    if affiliate_feature_additions_grouping.any?
      setup_email("usagov@searchsi.com", __method__)
      @subject = ERB.new(@email_template_subject).result(binding)
      @affiliate_feature_additions_grouping = affiliate_feature_additions_grouping
      mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
        format.text { render :text => ERB.new(@email_template_body).result(binding) }
      end
    end
  end

  def feature_admonishment(user, affiliates_with_unused_features)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @affiliates_with_unused_features = affiliates_with_unused_features
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_user_email_verification(user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_user(user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_developer(user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def mobile_feedback(email, message)
    setup_email(I18n.t(:mobile_feedback_contact_recipients), __method__)
    @from = email
    @subject = ERB.new(@email_template_subject).result(binding)
    charset "iso-8859-1"
    @message = message
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_affiliate_site(affiliate, user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @affiliate = affiliate
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def new_affiliate_user(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @affiliate = affiliate
    @user = user
    @current_user = current_user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @user = user
    @affiliate = affiliate
    @current_user = current_user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def saucelabs_report(admin_email, sauce_labs_link)
    setup_email(admin_email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @sauce_labs_link = sauce_labs_link
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def objectionable_content_alert(recipient, terms)
    setup_email(recipient, __method__)
    content_type "text/html"
    @subject = ERB.new(@email_template_subject).result(binding)
    @search_terms = terms
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def affiliate_header_footer_change(affiliate)
    recipients = affiliate.users.collect(&:email).join(', ') + ", #{DEVELOPERS_EMAIL}"
    setup_email(recipients, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @affiliate = affiliate
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  def affiliate_monthly_report(user, report_date)
    setup_email(user.email, __method__)
    @subject = ERB.new(@email_template_subject).result(binding)
    @report_date = report_date
    last_month = @report_date - 1.month
    last_year = @report_date - 1.year
    @affiliate_stats = {}
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
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) }
    end
  end

  private

  def setup_email(recipients, method_name)
    @from = APP_EMAIL_ADDRESS
    @sent_on = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
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