class Sites::UsersController < Sites::SetupSiteController
  def index
    @users = @site.users
  end

  def new
    @user = @site.users.new
  end

  def create
    @user = User.find_by_email user_params[:email].strip
    if @user.nil?
      @user = User.new_invited_by_affiliate(current_user, @site, user_params)
      if @user.save
        message = "We've created a temporary account and notified #{@user.email} on how to login and to access this site."
        redirect_to site_users_path(@site), flash: { success: message }
      else
        render action: :new
      end
    elsif !@site.users.exists?(@user)
      @site.users << @user
      Emailer.new_affiliate_user(@site, @user, current_user).deliver
      redirect_to site_users_path(@site), flash: { success: "You have added #{@user.email} to this site." }
    else
      @user = User.new user_params
      flash.now[:notice] = "#{@user.email} already has access to this site."
      render action: :new
    end
  end

  def destroy
    @user = User.find params[:id]
    Membership.where(user_id: @user.id, affiliate_id: @site.id).destroy_all
    redirect_to site_users_path(@site), flash: { success: "You have removed #{@user.email} from this site." }
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit(:contact_name, :email)
  end
end
