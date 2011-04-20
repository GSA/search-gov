class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create
    config.columns = [:email, :contact_name, :affiliates, :last_login_at, :last_login_ip, :last_request_at, :created_at]
    config.update.columns = [:affiliates, :email, :contact_name, :organization_name, :address, :address2, :phone, :city, :state, :zip, :is_affiliate_admin, :is_analyst, :is_affiliate, :is_analyst_admin]
    config.list.sorting = { :email => :asc }
    config.columns[:affiliates].form_ui = :select
    config.columns[:affiliates].options = { :draggable_lists => true }
    config.columns[:state].form_ui = :select
    config.columns[:state].options = ActionView::Helpers::FormOptionsHelper::US_STATES
    config.columns[:is_affiliate_admin].description = "Set this to true to make the user an Administrator, and give them access to the Admin Center."
    config.columns[:is_analyst].description = "Set this to true to make the user an Analyst, and give them access to the Analytics Center."
    config.columns[:is_affiliate].description = "Set this to true to make the user an Affiliate, and give them access to the Affiliate Center."
    config.columns[:is_analyst_admin].description = "Set this to true to make the user an Analytics Admin, and give them the ability to create and edit Query Groups."
  end
end