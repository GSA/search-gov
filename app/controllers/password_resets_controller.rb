class PasswordResetsController < SslController
  layout 'affiliates'
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email].to_s) if params[:email].present?
    if @user
      @user.deliver_password_reset_instructions!(request.host_with_port)
      flash.now[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
    else
      flash.now[:notice] = "No user was found with that email address"
    end
    render :action => :new
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    redirect_to home_page_path unless @user
  end
end
