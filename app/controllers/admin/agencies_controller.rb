class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agency do |config|
    config.columns = [:id, :name, :abbreviation, :organization_code, :federal_register_agency, :domain, :affiliates, :agency_urls, :phone, :toll_free_phone, :tty_phone, :twitter_username, :facebook_username, :youtube_username, :flickr_url, :name_variants, :agency_queries]
    config.columns.add :affiliates
    config.columns[:affiliates].form_ui = :select
    config.columns[:affiliates].options = {:draggable_lists => true}

    config.columns[:federal_register_agency].form_ui = :select

    config.actions.exclude :search
    config.actions.add :field_search, :export
    config.field_search.columns = [:name, :abbreviation, :organization_code, :domain, :affiliates, :twitter_username, :facebook_username, :youtube_username]
    config.list.columns.exclude [:agency_queries, :created_at, :updated_at, :toll_free_phone, :tty_phone, :flickr_url]
    config.export.columns.exclude :agency_queries
    config.export.columns.add :federal_register_agency_id
    config.columns[:federal_register_agency_id].label = 'Federal register agency ID'
  end
end
