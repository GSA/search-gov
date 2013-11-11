class ChangeTwitterIdOnTwitterProfiles < ActiveRecord::Migration
  def up
    change_column :twitter_profiles, :twitter_id, 'bigint unsigned', null: false
  end

  def down
    change_column :twitter_profiles, :twitter_id, :integer, null: true
  end
end
