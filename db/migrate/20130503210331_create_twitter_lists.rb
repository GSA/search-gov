class CreateTwitterLists < ActiveRecord::Migration
  def change
    create_table :twitter_lists, id: false do |t|
      t.integer :id, limit: 8, null: false
      t.text :member_ids, limit: 256.kilobytes
      t.integer :last_status_id, default: 1, limit: 8, null: false
      t.string :statuses_updated_at

      t.timestamps
    end
    add_index :twitter_lists, :id, unique: true
  end
end
