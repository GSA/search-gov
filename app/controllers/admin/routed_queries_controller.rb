class Admin::RoutedQueriesController < Admin::AdminController
  active_scaffold :routed_query do |config|
    config.columns[:affiliate].form_ui = :select
    config.columns[:affiliate].label = 'Site'
  end
end
