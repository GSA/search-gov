class Admin::AffiliatesController < Admin::AdminController
  before_filter :require_affiliate_admin

  active_scaffold :affiliate do |config|
    config.columns = [:name, :domains, :header, :footer]
    config.list.sorting = { :name => :asc }
  end

  private

  def require_affiliate_admin
    return false if require_user == false
    unless current_user.is_affiliate_admin?
      redirect_to home_page_url
      return false
    end
  end
end