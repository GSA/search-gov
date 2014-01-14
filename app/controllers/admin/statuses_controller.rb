class Admin::StatusesController < Admin::AdminController
  active_scaffold :status do |config|
    config.label = 'Site Statuses'
    config.list.columns = [:id, :name, :affiliates]
    config.create.columns = [:id, :name]
    config.update.columns.exclude :affiliates
  end
end
