class Admin::I14yDrawersController < Admin::AdminController
  active_scaffold :i14y_drawer do |config|
    config.actions.exclude :create, :delete
    config.list.sorting = { :created_at => :asc }
    config.columns = [:handle, :description, :i14y_memberships, :token, :created_at, :updated_at]
    config.update.columns = [:description, :i14y_memberships]
  end
end
