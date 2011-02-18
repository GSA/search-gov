class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create
    config.columns = [:email, :contact_name, :affiliates, :last_login_at, :last_request_at, :created_at]
    config.update.columns = [:affiliates, :email, :contact_name, :organization_name, :address, :address2, :phone, :city, :state, :zip, :is_affiliate_admin, :is_analyst, :is_affiliate, :is_analyst_admin]
    config.list.sorting = { :email => :asc }
    config.list.per_page = 100
    config.columns[:affiliates].form_ui = :select
    config.columns[:affiliates].options = { :draggable_lists => true }
    config.columns[:state].form_ui = :select
    config.columns[:state].options = ActionView::Helpers::FormOptionsHelper::US_STATES
  end
end