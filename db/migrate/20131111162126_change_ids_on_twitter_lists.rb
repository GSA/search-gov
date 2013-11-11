class ChangeIdsOnTwitterLists < ActiveRecord::Migration
  def up
    change_column :twitter_lists, :id, 'bigint unsigned'
    change_column :twitter_lists, :last_status_id, 'bigint unsigned'
  end

  def down
    change_column :twitter_lists, :last_status_id, :bigint
    change_column :twitter_lists, :id, :bigint
  end
end
