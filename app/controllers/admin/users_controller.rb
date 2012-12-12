class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create, :delete
    config.columns = [:email, :contact_name, :affiliates, :last_login_at, :last_login_ip, :last_request_at, :created_at]
    config.update.columns = [:email, :contact_name, :organization_name, :address, :address2, :phone, :city, :state, :zip, :is_affiliate_admin, :is_affiliate, :approval_status, :welcome_email_sent, :notes]
    config.list.sorting = { :email => :asc }
    config.columns[:state].form_ui = :select
    config.columns[:state].options = { :options => ActionView::Helpers::FormOptionsHelper::US_STATES }
    config.columns[:is_affiliate_admin].description = "Set this to true to make the user an Administrator, and give them access to the Admin Center."
    config.columns[:is_affiliate].description = "Set this to true to make the user an Affiliate, and give them access to the Affiliate Center."
    config.columns[:approval_status].form_ui = :select
    config.columns[:approval_status].options = { :options => User::APPROVAL_STATUSES }
    actions.add :export
    export.columns = [:email, :contact_name, :affiliate_names, :last_login_at, :last_login_ip, :last_request_at, :created_at, :organization_name, :address, :address2, :phone, :city, :state, :zip, :is_affiliate_admin, :is_affiliate, :approval_status, :welcome_email_sent, :notes]
  end
end