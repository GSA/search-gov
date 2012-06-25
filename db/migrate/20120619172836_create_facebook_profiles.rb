class CreateFacebookProfiles < ActiveRecord::Migration
  def self.up
    create_table :facebook_profiles do |t|
      t.string :username
      t.references :affiliate

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_profiles
  end
end
