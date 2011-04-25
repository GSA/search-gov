class EmailVerificationController < ApplicationController
  layout "account"
  before_filter :require_user

  def show
    @user = @current_user
    if @user.verify_email(params[:id])
      flash[:notice] = '<p>Thank you for verifying your email.</p>'
      if @user.is_pending_approval?
        flash[:notice] += "<p>Because you don't have a .gov or .mil email address, your account is pending approval.</p>"
        flash[:notice] += "<p>We will be in touch with you within two business days to confirm that you are a government employee or contractor and to set up your account.</p>"
        flash[:notice] += "<p>Regards,<br />The USASearchTeam<br />usasearch.gsa.gov</p>"
      end
    else
      flash[:notice] = 'Sorry! Your email verification is invalid. Are you sure you copied the right link from your email?'
    end
    redirect_to home_affiliates_path
  end
end

