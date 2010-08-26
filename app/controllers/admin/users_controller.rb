class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create, :delete
    config.columns = [:email, :contact_name, :affiliates, :last_login_at]
    config.update.columns = [:affiliates, :email, :contact_name, :organization_name, :address, :address2, :phone, :city, :state, :zip]
    config.list.sorting = { :email => :asc }
    config.list.per_page = 100
    config.columns[:affiliates].form_ui= :select
    config.columns[:state].form_ui= :usa_state
  end
end