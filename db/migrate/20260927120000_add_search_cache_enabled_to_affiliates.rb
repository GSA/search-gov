class AddSearchCacheEnabledToAffiliates < ActiveRecord::Migration[7.1]
  def change
    add_column :affiliates, :search_cache_enabled, :boolean, default: false, null: false
  end
end
