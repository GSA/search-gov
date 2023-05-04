class AddShowRedesignDisplaySettingsToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :show_redesign_display_settings, :boolean, :default => false
  end
end
