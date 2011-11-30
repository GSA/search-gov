class AddTopSearchesLabelToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :top_searches_label, :string, :default => 'Search Trends'
  end

  def self.down
    remove_column :affiliates, :top_searches_label
  end
end
