class DropQdIndex < ActiveRecord::Migration
  def up
    remove_index :daily_query_stats, :name => 'qd'
  end

  def down
    add_index :daily_query_stats, [:query, :day], :name => 'qd'
  end
end
