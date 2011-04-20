class Admin::ClicksController < Admin::AdminController
  active_scaffold :click do |config|
    config.actions.exclude :create, :delete, :update
    config.list.sorting = { :id => :desc }
  end
end