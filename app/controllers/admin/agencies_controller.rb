class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agency do |config|
    config.columns = %i(name abbreviation organization_code federal_register_agency)

    config.columns[:federal_register_agency].form_ui = :select
    config.columns[:federal_register_agency_id].label = 'Federal register agency ID'

    config.list.sorting = { name: :asc }
    config.list.columns.exclude [:agency_queries, :created_at, :updated_at]

    config.actions.exclude :search
    config.actions.add :field_search, :export
    config.field_search.columns = [:name, :abbreviation, :organization_code]

    config.export.columns.exclude :agency_queries
    config.export.columns.add :federal_register_agency_id
  end
end
