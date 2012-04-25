class CreateTwitterProfiles < ActiveRecord::Migration
  def self.up
    create_table :twitter_profiles do |t|
      t.integer :twitter_id
      t.string :screen_name, :length => 15

      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_profiles
  end
end
