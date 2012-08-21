class Admin::FormsController < Admin::AdminController
  active_scaffold :form do |config|
    config.actions = [:list, :search, :delete, :show, :export]
    config.columns = [:form_agency, :number, :file_type,
                      :revision_date, :expiration_date, :indexed_documents,
                      :created_at, :updated_at]
    config.columns.exclude :details
    config.list.columns.exclude :url
    config.show.columns.add :url
    config.show.columns.add Form::DETAIL_FIELD_NAMES
    config.export.columns = config.show.columns
    config.export.default_deselected_columns = [:created_at, :updated_at]
  end
end
