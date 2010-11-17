class DevelopersController < UsersController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def index
    @user_session = UserSession.new
    @user = User.new_developer
  end
  
  def new
    @user = User.new_developer
  end

  def create
    @user = User.new_developer(params[:user])
    if @user.save
      flash[:success] = "Thank you for registering for USA.gov Search Services"
      redirect_to account_path
    else
      render :action => :new
    end
  end
end