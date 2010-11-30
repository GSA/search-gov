class AffiliateUsersController < AffiliateAuthController
  before_filter :require_affiliate
  before_filter :setup_affiliate
    
  def index
    @email = nil
  end
  
  def create
    @email = params[:email]
    @user = User.find_by_email(params[:email])
    if @user
      if !@affiliate.users.include?(@user)
        @affiliate.users << @user
        @email = nil
        flash.now[:success] = "Successfully added #{@user.contact_name} (#{@user.email})"
      elsif @affiliate.is_owner?(@user)
        flash.now[:error] = "That user is the current owner of this affiliate; you can not add them again."
      else
        flash.now[:error] = "That user is already associated with this affiliate; you can not add them again."
      end
    else
      flash.now[:error] = "Could not find user with email: #{@email}; please ask them to register as an affiliate with their email address."
    end
    render :action => :index
  end
  
  def destroy
    @user = User.find(params[:id])
    if @affiliate.is_owner?(@user)
      flash.now[:error] = "You can't remove the owner of the affiliate from the list of users."
    else
      @affiliate.users.delete(@user)
      flash.now[:success] = "Removed #{@user.contact_name} from affiliate."
    end
    render :action => :index
  end
end
