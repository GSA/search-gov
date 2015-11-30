class MandrillUserEmailer
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def send_new_affiliate_user(affiliate, inviter_user)
    send_user_email('new_affiliate_user', {
      adder_contact_name: inviter_user.contact_name,
      site_name: affiliate.display_name,
      site_handle: affiliate.name,
      site_homepage_url: affiliate.website,
      edit_site_url: email_url(:site_url, affiliate),
    })
  end

  def send_new_user_email_verification
    send_user_email('new_user_email_verification', {
      email_verification_url: email_url(:email_verification_url, user.email_verification_token)
    })
  end

  def send_password_reset_instructions
    send_user_email('password_reset_instructions', {
      password_reset_url: email_url(:edit_password_reset_url, user.perishable_token)
    })
  end

  def send_welcome_to_new_user
    send_user_email('welcome_to_new_user', {
      new_site_url: email_url(:new_site_url)
    })
  end

  def send_welcome_to_new_user_added_by_affiliate
    primary_affiliate = user.affiliates.first

    send_user_email('welcome_to_new_user_added_by_affiliate', {
      adder_contact_name: user.inviter.contact_name,
      site_name: primary_affiliate.display_name,
      edit_site_url: email_url(:site_url, primary_affiliate),
      account_url: email_url(:account_url),
      site_homepage_url: primary_affiliate.website,
      complete_registration_url: email_url(:edit_complete_registration_url, user.email_verification_token),
    })
  end

  protected

  def email_url(url_name, *params)
    send_params = [params].flatten + [MandrillAdapter.new.base_url_params]
    Rails.application.routes.url_helpers.send(url_name, *send_params)
  end

  def send_user_email(email_name, merge_fields)
    MandrillAdapter.new.send_user_email(user, email_name, merge_fields)
  end
end
