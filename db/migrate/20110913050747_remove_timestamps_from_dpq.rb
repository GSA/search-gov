class RemoveTimestampsFromDpq < ActiveRecord::Migration
  def self.up
    remove_column :daily_popular_queries, :created_at
    remove_column :daily_popular_queries, :updated_at
  end

  def self.down
    add_column :daily_popular_queries, :created_at, :datetime
    add_column :daily_popular_queries, :updated_at, :datetime
  end
end
