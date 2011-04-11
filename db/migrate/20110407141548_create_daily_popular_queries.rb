class CreateDailyPopularQueries < ActiveRecord::Migration
  def self.up
    create_table :daily_popular_queries do |t|
      t.date :day
      t.references :affiliate
      t.string :locale, :limit => 5
      t.string :query
      t.integer :times
      t.boolean :is_grouped, :default => false
      t.integer :time_frame
      t.timestamps
    end
    add_index :daily_popular_queries, [:day, :affiliate_id, :locale, :is_grouped, :time_frame], :name => "dalit_index"
  end

  def self.down
    drop_table :daily_popular_queries
  end
end
