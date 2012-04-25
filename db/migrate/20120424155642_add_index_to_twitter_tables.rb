class AddIndexToTwitterTables < ActiveRecord::Migration
  def self.up
    add_index :twitter_profiles, :twitter_id
    add_index :tweets, :twitter_profile_id
  end

  def self.down
    remove_index :twitter_profiles, :twitter_id
    remove_index :tweets, :twitter_profile_id
  end
end
