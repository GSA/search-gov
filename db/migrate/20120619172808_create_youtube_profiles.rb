class CreateYoutubeProfiles < ActiveRecord::Migration
  def self.up
    create_table :youtube_profiles do |t|
      t.string :username
      t.references :affiliate

      t.timestamps
    end
  end

  def self.down
    drop_table :youtube_profiles
  end
end
