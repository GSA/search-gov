class AlterIndexOnMonthlyPopularQuery < ActiveRecord::Migration
  def self.up
    remove_index :monthly_popular_queries, [:year, :month]
    add_index :monthly_popular_queries, [:year, :month, :is_grouped]
  end

  def self.down
    remove_index :monthly_popular_queries, [:year, :month, :is_grouped]
    add_index :monthly_popular_queries, [:year, :month]
  end
end
