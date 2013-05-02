class Admin::AffiliateScopesController < Admin::AdminController
  active_scaffold :affiliate do |config|
    config.label = 'Customer Scopes'
    config.columns = [:display_name, :scope_ids]
    config.list.sorting = { :display_name => :asc }
    config.update.columns = [:scope_ids]
    config.columns[:scope_ids].description = "Enter one or more scope ids separated by commas."
    config.actions.exclude :create, :delete
  end
end