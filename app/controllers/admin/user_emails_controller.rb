class Admin::UserEmailsController < Admin::AdminController
  before_filter :load_user_and_template

  rescue_from 'MandrillAdapter::NoClient' do
    render :no_client
  end

  def index
    @template_names = MandrillAdapter.new.template_names
  end

  def merge_tags
    begin
      @preview = MandrillAdapter.new.preview_info(@user, @template_name)
      @send_to = @preview[:to_admin] ? :send_to_admin : :send_to_user
    rescue MandrillAdapter::UnknownTemplate => ut
      flash.now[:error] = "Unknown template '#{@template_name}'."
    end
  end

  def send_to_admin
    result = MandrillAdapter.new.send_admin_email(@user, @template_name, merge_vars)

    flash[:notice] = "email #{@template_name} sent to admin"
    redirect_to action: :index, id: @user.id
  end

  def send_to_user
    result = MandrillAdapter.new.send_user_email(@user, @template_name, merge_vars)

    flash[:notice] = "email #{@template_name} sent to user"
    redirect_to action: :index, id: @user.id
  end

  private

  def load_user_and_template
    @user = User.find(params[:id])
    @template_name = params[:email_id]
  end

  def merge_vars
    result = request.POST.clone
    ['authenticity_token', 'utf8'].each { |p| result.delete(p) }
    result
  end
end
