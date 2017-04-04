class UserSessionsController < SslController
  before_filter :reset_session, only: [:destroy]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

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
      render :action => :new
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
    @user_session.secure = UsasearchRails3::Application.config.ssl_options[:secure_cookies]
  end
end
