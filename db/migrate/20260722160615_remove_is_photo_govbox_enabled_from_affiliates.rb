class RemoveIsPhotoGovboxEnabledFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    remove_column :affiliates, :is_photo_govbox_enabled, :boolean
  end
end
