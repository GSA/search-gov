class Admin::UsersController < Admin::AdminController
  before_filter :require_affiliate_admin

  active_scaffold :user do |config|
    config.actions.exclude :create, :delete    
    config.columns = [:email, :contact_name, :affiliates]
    config.list.sorting = { :email => :asc }
    config.columns[:affiliates].form_ui= :select
  end
end