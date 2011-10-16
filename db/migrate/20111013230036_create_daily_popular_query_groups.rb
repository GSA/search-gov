class CreateDailyPopularQueryGroups < ActiveRecord::Migration
  def self.up
    create_table :daily_popular_query_groups do |t|
      t.date :day
      t.integer :time_frame
      t.string :query_group_name
      t.integer :times
    end
    add_index :daily_popular_query_groups, :day
  end

  def self.down
    drop_table :daily_popular_query_groups
  end
end
