class PasswordResetsController < SslController
  layout 'affiliates'
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :load_user_by_email, only: [:create]
  before_filter :reject_not_approved_user, only: [:create, :edit, :update]

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

  def load_user_by_email
    @user = User.find_by_email(params[:email].to_s) if params[:email].present?
  end

  def reject_not_approved_user
    if @user && @user.is_not_approved?
      redirect_to USA_GOV_URL
      false
    end
  end
end
