class CompleteRegistrationController < ApplicationController
  before_action :load_user_using_email_verification_token, :only => [:edit, :update]

  def edit
  end

  def update
    if @user.complete_registration(user_params[:user])
      flash[:success] = 'You have successfully completed your account registration.'
      redirect_to sites_path
    else
      render :action => :edit
    end
  end

  private

  def user_params
    params.permit(user: [:contact_name, :email, :organization_name, :password])
  end

  def load_user_using_email_verification_token
    @user = User.find_by_email_verification_token(params[:id])
    unless @user
      flash[:notice] = 'Sorry! Your request to complete registration is invalid. Are you sure you copied the right link from your email?'
      redirect_to login_path unless @user
    end
  end
end
