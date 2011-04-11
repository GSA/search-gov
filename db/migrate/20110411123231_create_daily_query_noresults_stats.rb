class CreateDailyQueryNoresultsStats < ActiveRecord::Migration
  def self.up
    create_table :daily_query_noresults_stats do |t|
      t.date :day, :null => false
      t.string :affiliate, :null => false
      t.string :locale, :null => false
      t.string :query, :null => false
      t.integer :times, :null => false
    end
    add_index :daily_query_noresults_stats, [:day, :affiliate, :locale, :query], :unique => true, :name => "dalq"
  end

  def self.down
    drop_table :daily_query_noresults_stats
  end
end
