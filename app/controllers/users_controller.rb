class UsersController < SslController
  layout "account"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def create
    @user = User.new(params[:user])
    if verify_recaptcha(:model => @user, :message => 'Word verification is incorrect') && @user.save
      if @user.is_affiliate? and !@user.is_government_affiliated_email?
        flash[:success] = "We do not recognize your email address as being affiliated with a government agency. Your account is pending approval. We will notify you when you are setup."
      else
        flash[:success] = "Thank you for registering for USA.gov Search Services"
      end

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
