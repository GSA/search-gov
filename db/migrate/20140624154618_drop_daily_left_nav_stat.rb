class DropDailyLeftNavStat < ActiveRecord::Migration
  def up
    drop_table :daily_left_nav_stats
  end

  def down
    create_table :daily_left_nav_stats do |t|
      t.references :affiliate, :null => false
      t.date :day, :null => false
      t.string :search_type, :null => false
      t.string :params
      t.integer :total, :null => false, :default => 0
    end
    add_index :daily_left_nav_stats, [:affiliate_id, :day]
  end
end
