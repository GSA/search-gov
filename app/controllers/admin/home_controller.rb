class Admin::HomeController < Admin::AdminController
  include Accountable
  before_action :check_user_account_complete

  def index; end
end
