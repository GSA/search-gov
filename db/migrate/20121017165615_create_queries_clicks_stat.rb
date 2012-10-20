class CreateQueriesClicksStat < ActiveRecord::Migration
  def change
    create_table :queries_clicks_stats do |t|
      t.string :affiliate, :null => false, :limit => 32
      t.string :query, :null => false
      t.date :day, :null => false
      t.string :url, :null => false, :limit => 2000
      t.integer :times, :null => false
    end
    add_index :queries_clicks_stats, [:affiliate, :query, :day], :name => 'aqd'
    add_index :queries_clicks_stats, [:affiliate, :url, :day], :name => 'aud'
  end
end
