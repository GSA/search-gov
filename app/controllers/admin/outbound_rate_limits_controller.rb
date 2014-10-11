class Admin::OutboundRateLimitsController < Admin::AdminController
  active_scaffold :outbound_rate_limit do |config|
    config.actions = [:list, :update]
    config.list.sorting = { name: :asc }
    config.columns[:limit].label = 'Limit / data center'
  end
end
