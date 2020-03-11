class UsersController < ApplicationController
  layout 'sites'
  before_action :require_user, :only => [:show, :edit, :update]
  before_action :set_user, except: :create

  def create
    @user = User.new(user_params)
    if verify_recaptcha(:model => @user, :message => 'Word verification is incorrect') && @user.save
      if @user.has_government_affiliated_email?
        flash[:success] = "Thank you for signing up. To continue the signup process, check your inbox, so we may verify your email address."
      else
        flash[:success] = "Sorry! You don't have a .gov or .mil email address so we need some more information from you before approving your account."
      end
      redirect_to account_path
    else
      flash.delete(:recaptcha_error)
      render action: :new, layout: 'application'
    end
  end

  def show
    message = <<~MESSAGE
      Because you don't have a .gov or .mil email address, we need additional information.
      If you are a contractor on an active contract, please use your .gov or .mil email
      address on this account, or have your federal POC email search@support.digitalgov.gov
      to confirm your status.
    MESSAGE

    flash[:notice] = message unless @user.has_government_affiliated_email? ||
                                    @user.approval_status == 'approved'
  end

  def edit; end

  def update_account
    @user.attributes = user_params
    if @user.save(context: :update_account)
      flash[:success] = 'Account updated!'
      redirect_to account_url
    else
      render :edit
    end
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Account updated!"
      redirect_to account_url
    else
      render :edit
    end
  end

  def developer_redirect; end

  private

  def require_user
    redirect_to developer_redirect_url if super.nil? and current_user.is_developer?
  end

  def set_user
    @user = @current_user.presence || current_user
  end

  def user_params
    params.require(:user).permit(:first_name,
                                 :last_name,
                                 :organization_name,
                                 :email).to_h
  end
end
