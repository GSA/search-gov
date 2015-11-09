class Admin::WatchersController < Admin::AdminController
  active_scaffold :watcher do |config|
    config.label = 'Analytics Alerts'
    config.actions.exclude :create, :delete, :edit, :update, :search
    config.actions.add :field_search
    config.field_search.columns = [:affiliate, :user, :name, :type]
    config.list.sorting = { created_at: :desc }
    config.columns[:throttle_period].label = 'Time between alerts'
    config.columns[:query_blocklist].label = 'Ignored query terms'
    config.columns[:time_window].label = 'Time window for each check'
  end
end
