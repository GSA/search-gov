class RemoveTopSearchesLabel < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :top_searches_label
  end

  def self.down
    add_column :affiliates, :top_searches_label, :string, :default => 'Search Trends'
  end
end
