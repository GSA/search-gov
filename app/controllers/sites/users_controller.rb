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
      @user.send_new_affiliate_user_email(@site, current_user)
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
    add_nutshell_note_for_user('added', 'to')
  end

  def audit_trail_user_removed
    add_nutshell_note_for_user('removed', 'from')
  end

  def add_nutshell_note_for_user(added_or_removed, to_or_from)
    note = "@[Contacts:#{current_user.nutshell_id}] #{added_or_removed} @[Contacts:#{@user.nutshell_id}], #{@user.email} #{to_or_from} @[Leads:#{@site.nutshell_id}] #{@site.display_name} [#{@site.name}]."
    NutshellAdapter.new.new_note(@user, note)
  end
end
