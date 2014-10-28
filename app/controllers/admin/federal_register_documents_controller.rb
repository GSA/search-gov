class Admin::FederalRegisterDocumentsController < Admin::AdminController
  active_scaffold :federal_register_document do |config|
    config.label = 'Federal Register Documents'
    config.actions = [:list, :show]

    config.list.columns = [:id,
                           :document_number,
                           :docket_id,
                           :document_type,
                           :title,
                           :html_url,
                           :publication_date,
                           :comments_close_on,
                           :created_at,
                           :updated_at]
    config.list.sorting = [{ publication_date: :desc }, { id: :asc }]

    config.columns[:docket_id].label = 'Docket ID'
    config.columns[:federal_register_agencies].associated_limit = nil

    config.actions.add :field_search
    config.field_search.columns = %i(federal_register_agencies document_type document_number docket_id)
  end
end
