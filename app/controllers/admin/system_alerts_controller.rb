class Admin::SystemAlertsController < Admin::AdminController
  active_scaffold :system_alert do |config|
    config.label = 'System Alerts'
    config.columns = [:message, :start_at, :end_at]
    config.columns[:start_at].form_ui = :datetime_picker
    config.columns[:start_at].description = 'UTC/GMT'
    config.columns[:end_at].form_ui = :datetime_picker
    config.columns[:end_at].description = 'UTC/GMT'
    config.list.sorting = { :start_at => :asc }
  end
end