class Admin::BingUrlsController < Admin::AdminController
  active_scaffold :bing_url do |config|
    config.label = 'Bing URLs'
    config.actions = [:list, :search, :delete, :export]
    config.export.default_deselected_columns = [:created_at, :updated_at]
  end
end