class UserSessionsController < SslController
  layout "account"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if @user_session.user.is_analyst?
        redirect_back_or_default analytics_home_page_path
      else
        redirect_back_or_default home_affiliates_path
      end
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default new_user_session_url
  end
end
