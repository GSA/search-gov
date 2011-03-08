class UserSessionsController < SslController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
    @user = User.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if @user_session.user.is_analyst?
        redirect_back_or_default analytics_home_page_path
      elsif @user_session.user.is_developer?
        redirect_back_or_default account_path
      else
        redirect_back_or_default home_affiliates_path
      end
    else
      @user = User.new
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default login_url
  end
end
