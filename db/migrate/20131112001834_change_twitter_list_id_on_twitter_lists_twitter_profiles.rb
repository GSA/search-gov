class ChangeTwitterListIdOnTwitterListsTwitterProfiles < ActiveRecord::Migration
  def up
    change_column :twitter_lists_twitter_profiles, :twitter_list_id, 'bigint unsigned'
  end

  def down
    change_column :twitter_lists_twitter_profiles, :twitter_list_id, :bigint
  end
end
