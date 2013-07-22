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
      if @user_session.user.is_developer?
        redirect_back_or_default developer_redirect_url
      else
        redirect_back_or_default home_affiliates_path
      end
    elsif @user_session.errors and @user_session.errors.values.flatten.join.include?('is not approved')
      redirect_to USA_GOV_URL
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
