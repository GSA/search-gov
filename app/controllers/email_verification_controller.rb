class EmailVerificationController < ApplicationController
  def show
    if current_user and current_user.verify_email(token)
      notice_message = '<p>Thank you for verifying your email.</p>'
      if current_user.is_pending_approval?
        notice_message << "<p>Because you don't have a .gov or .mil email address, your account is pending approval.</p>"
        notice_message << "<p>We will be in touch with you within two business days to confirm that you are a government employee or contractor and to set up your account.</p>"
      end
      flash[:notice] = notice_message.html_safe

      redirect_to account_path
    else
      current_user_session.try(:destroy)
      store_location
      verifying_user = User.find_by_email_verification_token(token)
      if verifying_user
        flash[:email_to_verify] = verifying_user.try(:email)
        flash[:notice] = 'Please log in to complete your email verification.'
      else
        flash[:notice] = 'Sorry! Your email verification link is invalid or expired. Are you sure you copied the right link from your most recent verification email?'
      end
      redirect_to login_path
    end
  end

  private

  def token
    @token ||= params[:id]
  end
end
