class CreateDailyQueryStats < ActiveRecord::Migration
  def self.up
    create_table :daily_query_stats do |t|
      t.date :day, :null => false
      t.string :query, :null => false
      t.integer :times, :null => false
    end
    add_index :daily_query_stats, [:day, :query], :unique => true
  end

  def self.down
    drop_table :daily_query_stats
  end
end
