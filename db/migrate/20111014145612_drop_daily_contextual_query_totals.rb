class DropDailyContextualQueryTotals < ActiveRecord::Migration
  def self.up
    drop_table :daily_contextual_query_totals
  end

  def self.down
    create_table :daily_contextual_query_totals do |t|
      t.date :day
      t.integer :total

      t.timestamps
    end
  end
end
