class AddNameToTwitterProfiles < ActiveRecord::Migration
  def self.up
    add_column :twitter_profiles, :name, :string, :null => false
  end

  def self.down
    remove_column :twitter_profiles, :name
  end
end
