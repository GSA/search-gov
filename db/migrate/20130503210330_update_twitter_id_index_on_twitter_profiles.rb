class UpdateTwitterIdIndexOnTwitterProfiles < ActiveRecord::Migration
  def up
    remove_index :twitter_profiles, :twitter_id
    add_index :twitter_profiles, :twitter_id, unique: true
  end

  def down
    remove_index :twitter_profiles, :twitter_id
    add_index :twitter_profiles, :twitter_id
  end
end
