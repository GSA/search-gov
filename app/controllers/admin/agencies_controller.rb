class Admin::AgenciesController < Admin::AdminController
  active_scaffold :agencies do |config|
    config.columns = [:name, :abbreviation, :domain, :agency_urls, :phone, :toll_free_phone, :tty_phone, :twitter_username, :facebook_username, :youtube_username, :flickr_url, :name_variants, :agency_queries]
    config.list.columns.exclude [:agency_queries, :created_at, :updated_at, :toll_free_phone, :tty_phone, :flickr_url]
  end
end
