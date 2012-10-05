class Admin::SystemAlertsController < Admin::AdminController
  active_scaffold :system_alert do |config|
    config.label = 'System Alerts'
    config.columns = [:message, :start_at, :end_at]
    config.columns[:start_at].form_ui = :calendar_date_select
    config.columns[:start_at].description = 'Format: 2012-10-05 00:00:00 UTC'
    config.columns[:end_at].form_ui = :calendar_date_select
    config.columns[:end_at].description = 'Format: 2012-10-05 00:00:00 UTC'
    config.list.sorting = { :start_at => :asc }
  end
end