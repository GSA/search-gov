class Admin::AffiliateScopeIdsController < Admin::AdminController
  active_scaffold :affiliate do |config|
    config.columns = [:display_name, :scope_ids]
    config.list.sorting = { :display_name => :asc }
    config.update.columns = [:scope_ids]
    config.columns[:scope_ids].description = "Enter one or more scope ids separated by commas."
  end
end
