class CompleteRegistrationController < SslController
  layout 'affiliates'
  before_filter :require_no_user
  before_filter :load_user_using_email_verification_token, :only => [:edit, :update]

  def edit
  end

  def update
    if @user.complete_registration(params[:user])
      flash[:success] = 'You have successfully completed your account registration.'
      redirect_to home_affiliates_path
    else
      render :action => :edit
    end
  end

  def default_url_options(options={})
    {}
  end

  private

  def load_user_using_email_verification_token
    @user = User.find_by_email_verification_token(params[:id])
    unless @user
      flash[:notice] = 'Sorry! Your request to complete registration is invalid. Are you sure you copied the right link from your email?'
      redirect_to login_path unless @user
    end
  end
end

