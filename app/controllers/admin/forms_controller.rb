class Admin::FormsController < Admin::AdminController
  active_scaffold :form do |config|
    config.actions = [:list, :search, :update, :delete, :show, :export]
    config.columns = [:form_agency, :number, :file_type, :verified,
                      :revision_date, :expiration_date, :indexed_documents,
                      :created_at, :updated_at]
    config.columns.exclude :details
    config.list.columns.exclude :url
    config.update.columns = :verified
    config.show.columns.add :url
    config.show.columns.add Form::DETAIL_FIELD_NAMES
    config.show.columns.add [:line_of_business, :subfunction, :public_code, :abstract]
    config.export.columns = config.show.columns
    config.export.default_deselected_columns = [:created_at, :updated_at]
  end
end
