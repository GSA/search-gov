class Admin::AdminController < ApplicationController
  newrelic_ignore
  layout "admin"
  before_action :require_affiliate_admin

  ActiveScaffold.set_defaults do |config|
    config.list.per_page = 100
  end

  private

  def require_affiliate_admin
    return false if require_user == false
    redirect_to('https://search.gov/access-denied') unless current_user.is_affiliate_admin?
  end
end
