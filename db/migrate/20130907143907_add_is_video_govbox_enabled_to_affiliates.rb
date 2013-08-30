class AddIsVideoGovboxEnabledToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :is_video_govbox_enabled, :boolean, default: true, null: false
  end
end
