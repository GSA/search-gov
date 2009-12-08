class Admin::AffiliatesController < Admin::AdminController
  before_filter :require_affiliate_admin

  active_scaffold :affiliate do |config|
    config.columns = [:name, :contact_email, :contact_name, :domains, :header, :footer]
    config.list.sorting = { :name => :asc }
  end

end