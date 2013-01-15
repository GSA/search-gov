class Admin::ReportRecipientsController < Admin::AdminController
  active_scaffold :report_recipient do |config|
    config.label = 'Monthly/Weekly Report Recipients'
  end
end
