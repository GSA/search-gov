class Sites::UsersController < Sites::SetupSiteController
  include ::Hintable

  before_filter :load_hints, only: %i(create new)

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
        NutshellAdapter.new.push_site @site
        audit_trail_user_added
        message = "We've created a temporary account and notified #{@user.email} on how to login and to access this site."
        redirect_to site_users_path(@site), flash: { success: message }
      else
        render action: :new
      end
    elsif !@site.users.exists?(@user)
      @site.users << @user
      Emailer.new_affiliate_user(@site, @user, current_user).deliver
      NutshellAdapter.new.push_site @site
      audit_trail_user_added
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
    NutshellAdapter.new.push_site @site
    audit_trail_user_removed
    redirect_to site_users_path(@site), flash: { success: "You have removed #{@user.email} from this site." }
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit(:contact_name, :email)
  end

  def audit_trail_user_added
    NutshellAdapter.new.new_note(@user, "@[Contacts:#{current_user.nutshell_id}] added @[Contacts:#{@user.nutshell_id}], #{@user.email} to @[Leads:#{@site.nutshell_id}] #{@site.display_name} [#{@site.name}].")
  end

  def audit_trail_user_removed
    note = "@[Contacts:#{current_user.nutshell_id}] removed @[Contacts:#{@user.nutshell_id}], #{@user.email} from @[Leads:#{@site.nutshell_id}] #{@site.display_name} [#{@site.name}]."
    if @user.affiliates.empty?
      note += " This user is no longer associated with any sites, so their approval status has been set to 'not_approved'."
    end

    NutshellAdapter.new.new_note(@user, note)
  end
end
