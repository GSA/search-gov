class Admin::GroupedQueriesController < Admin::AdminController
  active_scaffold :grouped_queries do |config|
    config.columns = [:query]
  end
end