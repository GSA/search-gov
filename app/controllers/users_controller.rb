class UsersController < SslController
  layout "account"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Thank you for registering for USA.gov Search Services"
      if @user.is_affiliate?
        redirect_to home_affiliates_path
      else
        redirect_to account_path
      end
    else
      @user_session = UserSession.new
      render :template => "user_sessions/new", :layout => "user_sessions"
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:success] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
