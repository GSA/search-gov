# frozen_string_literal: true

class LandingPageFinder
  include Rails.application.routes.url_helpers

  ACCESS_DENIED_TEXT =
    'Access Denied: These credentials are not recognized as valid' \
    ' for accessing Search.gov. Please reach out to' \
    ' search@support.digitalgov.gov if you believe this is in error.'

  class Error < StandardError
  end

  def initialize(user, return_to)
    @user = user
    @return_to = return_to
  end

  def landing_page
    destination_access_denied ||
      destination_edit_account ||
      destination_original ||
      destination_affiliate_admin ||
      destination_site_page ||
      new_site_path
  end

  private

  def destination_access_denied
    return nil if @user.login_allowed?

    raise Error, ACCESS_DENIED_TEXT
  end

  def destination_edit_account
    (@user.approval_status == 'pending_approval' && edit_account_path) ||
      (!@user.complete? && edit_account_path)
  end

  def destination_original
    @return_to
  end

  def destination_affiliate_admin
    @user.is_affiliate_admin? && admin_home_page_path
  end

  def destination_site_page
    @user.is_affiliate? && affiliate_site_page
  end

  def affiliate_site_page
    if @user.default_affiliate
      site_path(@user.default_affiliate)
    elsif !@user.affiliates.empty?
      site_path(@user.affiliates.first)
    end
  end
end
