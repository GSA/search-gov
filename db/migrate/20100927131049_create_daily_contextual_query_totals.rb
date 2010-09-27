class CreateDailyContextualQueryTotals < ActiveRecord::Migration
  def self.up
    create_table :daily_contextual_query_totals do |t|
      t.date :day
      t.integer :total

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_contextual_query_totals
  end
end
