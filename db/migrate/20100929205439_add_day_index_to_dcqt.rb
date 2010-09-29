class AddDayIndexToDcqt < ActiveRecord::Migration
  def self.up
    add_index :daily_contextual_query_totals, :day, :unique => true
  end

  def self.down
    remove_index :daily_contextual_query_totals, :day
  end
end
