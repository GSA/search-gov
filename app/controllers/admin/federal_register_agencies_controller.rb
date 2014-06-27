class Admin::FederalRegisterAgenciesController < Admin::AdminController
  active_scaffold :federal_register_agency do |config|
    config.label = 'Federal Register Agencies'
    config.actions = [:list, :show]
    config.columns = [:id, :name, :short_name, :created_at, :updated_at]
    list.sorting = { name: 'ASC' }

    config.actions.add :search
    config.search.columns = [:id, :name, :short_name]

    config.action_links.add :reimport, position: false, type: :collection
  end

  def reimport
    FederalRegisterAgencyData.import
    list
  end
end
