class Admin::GovFormsController < Admin::AdminController
  active_scaffold :gov_forms do |config|
    config.list.per_page = 100
  end
end
