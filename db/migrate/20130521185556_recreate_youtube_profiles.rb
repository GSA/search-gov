class RecreateYoutubeProfiles < ActiveRecord::Migration
  def change
    create_table :youtube_profiles do |t|
      t.string :username, null: false

      t.timestamps
    end
    add_index :youtube_profiles, :username, unique: true
  end
end
