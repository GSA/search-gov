class UserSessionsController < ApplicationController
  before_action :reset_session, only: %w[new create destroy]
  before_action :require_no_user, only: %w[new create]
  before_action :require_user, only: :destroy

  def new
    construct_user_session
  end

  def security_notification
    redirect_to(account_path) if current_user
  end

  def create
    construct_user_session(user_session_params)

    if @user_session.save
      redirect_back_or_default redirection_path
    else
      redirect_to(login_path)
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to(login_path)
  end

  private

  def construct_user_session(params = nil)
    @user_session =
      case params
      when nil
        UserSession.new
      else
        UserSession.new(params)
      end
    @user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end

  def user_session_params
    params.require(:user_session).permit(:email)
  end

  def redirection_path
    @user_session.user.is_developer? ? developer_redirect_url : sites_path
  end
end