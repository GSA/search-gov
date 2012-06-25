class CreateFlickrProfiles < ActiveRecord::Migration
  def self.up
    create_table :flickr_profiles do |t|
      t.string :url
      t.string :profile_type
      t.string :profile_id
      t.references :affiliate

      t.timestamps
    end
  end

  def self.down
    drop_table :flickr_profiles
  end
end
