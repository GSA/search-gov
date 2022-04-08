# frozen_string_literal: true

class LandingPageFinder
  include Rails.application.routes.url_helpers

  ACCESS_DENIED_TEXT = <<~MESSAGE
    Access Denied: These credentials are not recognized as valid
    for accessing Search.gov. Please reach out to
    #{SUPPORT_EMAIL_ADDRESS} if you believe this is in error.
  MESSAGE

  class Error < StandardError
  end

  def initialize(user, return_to)
    @user = user
    @return_to = return_to
  end

  def landing_page
    raise(Error, ACCESS_DENIED_TEXT) unless @user.login_allowed?

    destination_edit_account ||
      destination_original ||
      destination_affiliate_admin ||
      destination_site_page ||
      new_site_path
  end

  private

  def destination_edit_account
    edit_account_path if @user.approval_status == 'pending_approval' || !@user.complete?
  end

  def destination_original
    @return_to
  end

  def destination_affiliate_admin
    admin_home_page_path if @user.is_affiliate_admin?
  end

  def destination_site_page
    if @user.default_affiliate
      site_path(@user.default_affiliate)
    elsif !@user.affiliates.empty?
      site_path(@user.affiliates.first)
    end
  end
end
