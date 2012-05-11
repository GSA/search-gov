class Emailer < ActionMailer::Base
  default_url_options[:host] = APP_URL
  DEVELOPERS_EMAIL = "developers@searchsi.com"

  def password_reset_instructions(user)
    setup_email(user.email, __method__)
    @subject += "Password Reset Instructions"
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def new_user_to_admin(user)
    setup_email("usagov@searchsi.com", __method__)
    @subject += "New user signed up for USA Search Services"
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def new_feature_adoption_to_admin
    affiliate_feature_additions_grouping = AffiliateFeatureAddition.where(["created_at >= ?", Date.yesterday.beginning_of_day]).group_by(&:affiliate_id)
    if affiliate_feature_additions_grouping.any?
      setup_email("usagov@searchsi.com", __method__)
      @subject += "Features adopted by customers yesterday"
      @affiliate_feature_additions_grouping = affiliate_feature_additions_grouping
      mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
        format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
      end
    end
  end

  def feature_admonishment(user, affiliates_with_unused_features)
    setup_email(user.email, __method__)
    @subject += "Getting started with USASearch features"
    @affiliates_with_unused_features = affiliates_with_unused_features
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def new_user_email_verification(user)
    setup_email(user.email, __method__)
    @subject += 'Email Verification'
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def welcome_to_new_user(user)
    setup_email(user.email, __method__)
    @subject += "Welcome to the USASearch Affiliate Program"
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def welcome_to_new_developer(user)
    setup_email(user.email, __method__)
    @subject += "Welcome to the USASearch Program: APIs and Web Services"
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def mobile_feedback(email, message)
    setup_email(I18n.t(:mobile_feedback_contact_recipients), __method__)
    @from = email
    @subject = I18n.t(:mobile_feedback_subject)
    charset "iso-8859-1"
    @message = message
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end    
  end

  def new_affiliate_site(affiliate, user)
    setup_email(user.email, __method__)
    @subject += "Your new Affiliate site"
    @affiliate = affiliate
    @user = user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def new_affiliate_user(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @subject += "USASearch Affiliate Program: You Were Added to #{affiliate.display_name}"
    @affiliate = affiliate
    @user = user
    @current_user = current_user
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def welcome_to_new_user_added_by_affiliate(affiliate, user, current_user)
    setup_email(user.email, __method__)
    @subject += "Welcome to the USASearch Affiliate Program"
    @user = user
    @affiliate = affiliate
    @current_user = current_user
    if @email_template_body.blank?
      return false
    else
      mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
        format.text { render :text => ERB.new(@email_template_body).result(binding) }
      end
    end
  end

  def saucelabs_report(admin_email, sauce_labs_link)
    setup_email(admin_email, __method__)
    @subject += "Sauce Labs Report"
    @sauce_labs_link = sauce_labs_link
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def objectionable_content_alert(recipient, terms)
    setup_email(recipient, __method__)
    content_type "text/html"
    @subject += "Objectionable Content Alert"
    @search_terms = terms
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  def affiliate_header_footer_change(affiliate)
    recipients = affiliate.users.collect(&:email).join(', ') + ", #{DEVELOPERS_EMAIL}"
    setup_email(recipients, __method__)
    @subject += "The header and footer for #{affiliate.display_name} have been changed"
    @affiliate = affiliate
    mail(:to => @recipients, :subject => @subject, :from => @from, :date => @sent_on) do |format|
      format.text { render :text => ERB.new(@email_template_body).result(binding) } if @email_template_body
    end
  end

  private

  def setup_email(recipients, method_name)
    @from = APP_EMAIL_ADDRESS
    @subject = "[USASearch] "
    @sent_on = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-8; format=flowed"
    email_template = EmailTemplate.find_by_name(method_name)
    if email_template
      @recipients = recipients
      @email_template_body = email_template.body
    else
      @recipients = DEVELOPERS_EMAIL
      @email_template_body = "Someone tried to send an email via the #{method_name} method, but we don't have a template for that method.  Please create one.  Thanks!"
    end
  end
end