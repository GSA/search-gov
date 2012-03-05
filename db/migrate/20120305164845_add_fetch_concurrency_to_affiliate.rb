class AddFetchConcurrencyToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :fetch_concurrency, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :affiliates, :fetch_concurrency
  end
end
