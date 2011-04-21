class Affiliates::UsersController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def index
    @email = nil
    @title = "Manage Users - "
  end

  def create
    @email = params[:email]
    @contact_name = params[:name]
    @user = User.find_by_email(params[:email])
    if @user
      if @affiliate.users.include?(@user)
        flash.now[:error] = "That user is already associated with this affiliate. You cannot add them again."
      else
        @affiliate.users << @user
        @email, @contact_name = nil, nil
        flash.now[:success] = "Successfully added #{@user.contact_name} (#{@user.email})"
        Emailer.deliver_new_affiliate_user(@affiliate, @user, current_user)
      end
    else
      random_password = Digest::MD5.hexdigest("#{@email}:#{Time.now.to_s}")[0..8]
      @user = User.create(:email => @email, :contact_name => @contact_name, :government_affiliation => '1', :password => random_password, :password_confirmation => random_password, :skip_welcome_email => true)
      @affiliate.users << @user
      flash.now[:success] = "That user does not exist in the system. We've created a temporary account and notified them via email on how to login. Once they login, they will have access to the affiliate."
      Emailer.deliver_welcome_to_new_user_added_by_affiliate(@affiliate, @user, current_user)
    end
    redirect_to affiliate_users_path(@affiliate)
  end

  def destroy
    @user = User.find(params[:id])
    @affiliate.users.delete(@user)
    flash.now[:success] = "Removed #{@user.contact_name} from affiliate."
    if @user == current_user
      redirect_to home_affiliates_path
    else
      redirect_to affiliate_users_path(@affiliate)
    end
  end
end
