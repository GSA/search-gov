class RemoveShowRedesignDisplaySettingsFromAffiliates < ActiveRecord::Migration[7.0]
  def change
    remove_column :affiliates, :show_redesign_display_settings, :boolean, default: false
  end
end
