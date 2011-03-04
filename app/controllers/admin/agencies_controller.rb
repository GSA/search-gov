class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agencies do |config|
    config.columns = [:name, :abbreviation, :domain, :url, :es_url, :phone, :toll_free_phone, :tty_phone, :twitter_username, :facebook_username, :youtube_username, :flickr_username, :name_variants, :agency_queries]
    config.list.columns.exclude [:agency_queries, :es_url, :created_at, :updated_at]
  end
end
