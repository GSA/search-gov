class PasswordResetsController < ApplicationController
  before_action :require_no_user
  before_action :load_user_using_perishable_token, only: %i[edit update]
  before_action :load_user_by_email, only: [:create]
  before_action :reject_not_approved_user, only: %i[create edit update]

  def edit
    render
  end

  def update
    @user.require_password = true
    @user.password = params[:user][:password]
    if @user.save
      flash[:notice] = 'Password successfully updated'
      redirect_to account_path
    else
      render action: :edit
    end
  end

  def new
    render
  end

  def create
    @user&.deliver_password_reset_instructions!
    flash.now[:notice] = 'Instructions to reset your password have been '\
                         'emailed to you. Please check your email.'
    render :action => :new
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    if @user.blank?
      redirect_to new_password_reset_path, flash: { error: invalid_token_message }
    end
  end

  def load_user_by_email
    @user = User.find_by_email(params[:email].to_s) if params[:email].present?
  end

  def reject_not_approved_user
    if @user&.is_not_approved?
      redirect_to new_password_reset_path, flash: {
        notice: I18n.t('authlogic.error_messages.not_approved')
      }
      false
    end
  end

  def invalid_token_message
    'Sorry! This password reset link is invalid or expired.' \
    'Password reset links are valid for one hour. Please enter' \
    'your email below to receive a new link.'
  end
end
