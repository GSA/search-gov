class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agency do |config|
    config.columns = %i(id name abbreviation organization_code federal_register_agency domain affiliates agency_urls phone toll_free_phone tty_phone name_variants agency_queries affiliates)
    config.columns[:affiliates].form_ui = :select
    config.columns[:affiliates].options = {:draggable_lists => true}

    config.columns[:federal_register_agency].form_ui = :select
    config.columns[:federal_register_agency_id].label = 'Federal register agency ID'

    config.list.sorting = { name: :asc }
    config.list.columns.exclude [:agency_queries, :created_at, :updated_at, :toll_free_phone, :tty_phone, :flickr_url]

    config.actions.exclude :search
    config.actions.add :field_search, :export
    config.field_search.columns = [:name, :abbreviation, :organization_code, :domain, :affiliates, :twitter_username, :facebook_username, :youtube_username]

    config.export.columns.exclude :agency_queries
    config.export.columns.add :federal_register_agency_id
  end
end
