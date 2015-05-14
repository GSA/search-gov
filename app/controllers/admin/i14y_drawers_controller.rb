class Admin::I14yDrawersController < Admin::AdminController
  active_scaffold :i14y_drawer do |config|
    config.actions.exclude :create, :delete
    config.list.sorting = { :created_at => :asc }
    config.columns[:affiliate].form_ui = :select
    config.columns[:affiliate].label = 'Site'
    config.update.columns = [:description, :affiliate]
  end
end
