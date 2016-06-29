class UserSessionsController < SslController
  before_filter :reset_session, only: [:destroy]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
    @user = User.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
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
        @user = User.new
        render :action => :new
      end
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default login_url
  end
end
