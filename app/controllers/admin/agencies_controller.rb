class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agency do |config|
    config.columns = %i(name abbreviation agency_organization_codes federal_register_agency)

    config.columns[:federal_register_agency].form_ui = :select
    config.columns[:federal_register_agency_id].label = 'Federal register agency ID'

    config.list.sorting = { name: :asc }
    config.list.columns.exclude [:created_at, :updated_at]

    config.actions.exclude :search
    config.actions.add :field_search, :export
    config.field_search.columns = [:name, :abbreviation, :agency_organization_codes]

    config.export.columns.add :federal_register_agency_id
  end
end
