class Analytics::QueryGroupsController < Analytics::AnalyticsController
  active_scaffold :query_group do |config|
    config.columns = [:name, :updated_at, :grouped_queries]
    config.list.sorting = { :name => :asc }
  end
end