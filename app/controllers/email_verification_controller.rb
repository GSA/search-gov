class EmailVerificationController < ApplicationController
  layout "account"
  before_filter :require_user

  def show
    @user = @current_user
    if @user.verify_email(params[:id])
      flash[:notice] = 'Thank you for verifying your email.'
    else
      flash[:notice] = 'Sorry! Your email verification is invalid. Are you sure you copied the right link from your email?'
    end
    redirect_to home_affiliates_path
  end
end

