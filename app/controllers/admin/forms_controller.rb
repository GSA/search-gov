class Admin::FormsController < Admin::AdminController
  active_scaffold :form do |config|
    config.actions = [:list, :search, :delete, :show]
    config.columns.exclude :details
    config.list.columns.exclude :url
    config.show.columns.add :url
    config.show.columns.add Form::DETAIL_FIELD_NAMES
  end
end
