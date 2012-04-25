class CreateDailyLeftNavStats < ActiveRecord::Migration
  def self.up
    create_table :daily_left_nav_stats do |t|
      t.references :affiliate, :null => false
      t.date :day, :null => false
      t.string :search_type, :null => false
      t.string :params
      t.integer :total, :null => false, :default => 0
    end
    add_index :daily_left_nav_stats, [:affiliate_id, :day]
  end

  def self.down
    drop_table :daily_left_nav_stats
  end
end
