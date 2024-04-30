class AddShowSearchFilterSettingsToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :show_search_filter_settings, :boolean, default: false, null: false
  end
end
