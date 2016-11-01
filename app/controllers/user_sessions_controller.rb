class UserSessionsController < SslController
  before_filter :reset_session, only: [:destroy]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :require_password_reset, only: :create

  def new
    construct_user_session
  end

  def create
    construct_user_session(params[:user_session])
    if @user_session.save
      if @user_session.user.is_developer?
        redirect_back_or_default developer_redirect_url
      else
        redirect_back_or_default sites_path
      end
    else
      if params[:user_session][:email].present? and
          User.not_approved.exists?(email: params[:user_session][:email])
        redirect_to USA_GOV_URL
      else
        render :action => :new
      end
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default login_url
  end

  def require_password_reset
    user = User.find_by_email(params[:user_session][:email])

    if user && user.requires_password_reset?
      user.deliver_password_reset_instructions!
      flash[:notice] = "Looks like it's time to change your password! Please check your email for the password reset message we just sent you. Thanks!"
      redirect_to login_path
    end
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
    @user_session.secure = UsasearchRails3::Application.config.ssl_options[:secure_cookies]
  end
end
