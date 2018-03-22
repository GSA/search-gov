class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create, :delete
    config.columns = [:email, :contact_name, :memberships, :default_affiliate, :nutshell, :created_at, :updated_at, :approval_status]
    config.update.columns = [:email, :contact_name, :organization_name, :is_affiliate_admin, :is_affiliate, :approval_status, :default_affiliate, :welcome_email_sent]
    config.list.sorting = { :created_at => :desc }
    config.columns[:is_affiliate_admin].description = "Set this to true to make the user an Administrator, and give them access to the Admin Center."
    config.columns[:is_affiliate].description = "Set this to true to make the user an Affiliate, and give them access to the Affiliate Center."
    config.columns[:approval_status].form_ui = :select
    config.columns[:approval_status].options = { :options => User::APPROVAL_STATUSES }
    config.columns[:default_affiliate].actions_for_association_links = [:show]
    config.columns[:default_affiliate].form_ui = :select
    config.actions.add :export
    config.actions.exclude :search
    config.actions.add :field_search
    config.field_search.columns = %i(id email contact_name approval_status)

    export.columns = %i(email contact_name affiliate_names last_login_at last_login_ip last_request_at
                        created_at updated_at organization_name is_affiliate_admin is_affiliate approval_status
                        welcome_email_sent)
  end
end
