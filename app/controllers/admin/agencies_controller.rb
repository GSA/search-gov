class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agencies do |config|
    config.columns = [:name, :abbreviation, :domain, :url, :phone, :name_variants, :agency_queries]
    config.list.columns.exclude [:agency_queries, :created_at, :updated_at]
  end
end
