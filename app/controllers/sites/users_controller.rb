class Sites::UsersController < Sites::BaseController
  before_filter :setup_affiliate
  before_filter :setup_help_link

  def index
    @users = @affiliate.users
  end

  def new
    @user = @affiliate.users.new
  end

  def create
    @user = User.find_by_email user_params[:email].strip
    if @user.nil?
      @user = User.new_invited_by_affiliate(current_user, @affiliate, user_params)
      if @user.save
        message = "We've created a temporary account and notified #{@user.email} on how to login and to access this site."
        redirect_to site_users_path(@affiliate), flash: { success: message }
      else
        render action: :new
      end
    elsif !@affiliate.users.exists?(@user)
      @affiliate.users << @user
      Emailer.new_affiliate_user(@affiliate, @user, current_user).deliver
      redirect_to site_users_path(@affiliate), flash: { success: "You have added #{@user.email} to this site." }
    else
      @user = User.new user_params
      flash.now[:notice] = "#{@user.email} already has access to this site."
      render action: :new
    end
  end

  def destroy
    @user = User.find params[:id]
    @affiliate.users.delete @user
    redirect_to site_users_path(@affiliate), flash: { success: "You have removed #{@user.email} from this site." }
  end

  private

  def user_params
    @user_params ||= params[:user].slice(:contact_name, :email)
  end
end
