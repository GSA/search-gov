class UserSessionsController < ApplicationController
  before_action :reset_session, only: [:destroy]
  before_action :require_no_user, :only => [:new, :create]
  before_action :require_user, :only => :destroy

  def new
    construct_user_session
  end

  def create
    construct_user_session(user_session_params)

    if !require_password_reset && @user_session.save
      redirect_back_or_default redirection_path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default login_url
  end

  private

  def require_password_reset
    user = User.find_by_email(params[:user_session][:email])
    return false unless (@user_session.valid? && user.requires_password_reset?)

    user.deliver_password_reset_instructions!
    flash[:notice] = "Looks like it's time to change your password! Please check your email for the password reset message we just sent you. Thanks!"
  end

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
    params.require(:user_session).permit(:email, :password)
  end

  def redirection_path
    @user_session.user.is_developer? ? developer_redirect_url : sites_path
  end
end
