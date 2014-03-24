class ReAddQueryDayIndex < ActiveRecord::Migration
  def up
    add_index :daily_query_stats, [:query, :day], :name => 'qd'
  end

  def down
    remove_index :daily_query_stats, :name => 'qd'
  end
end
