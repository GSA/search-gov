class Admin::FederalRegisterAgenciesController < Admin::AdminController
  active_scaffold :federal_register_agency do |config|
    config.label = 'Federal Register Agencies'
    config.actions = [:list, :show]
    config.list.columns = [:id, :name, :short_name, :last_load_documents_requested_at, :created_at, :updated_at]
    config.list.sorting = { name: :asc }

    config.actions.add :search
    config.search.columns = [:id, :name, :short_name]

    config.action_links.add :reimport, position: false, type: :collection
  end

  def reimport
    FederalRegisterAgencyData.import
    list
  end
end
