class AddAffiliateIdToTopSearches < ActiveRecord::Migration
  def self.up
    add_column :top_searches, :affiliate_id, :integer
    add_index :top_searches, :affiliate_id
    remove_index :top_searches, :position
    add_index :top_searches, [:position, :affiliate_id], :unique => true
  end

  def self.down
    remove_index :top_searches, [:position, :affiliate_id]
    remove_index :top_searches, :affiliate_id
    remove_column :top_searches, :affiliate_id
    add_index :top_searches, :position, :unique => true
  end
end
