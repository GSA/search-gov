class UserSessionsController < ApplicationController
  before_filter :reset_session, only: [:destroy]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def security_notification; end

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
    redirect_back_or_default login_url
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
