class Analytics::GroupedQueriesController < Analytics::AnalyticsController
  active_scaffold :grouped_queries do |config|
    config.columns = [:query, :query_groups]
    config.list.per_page = 100
  end
end