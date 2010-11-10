class AddAffiliateIdToCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    add_column :calais_related_searches, :affiliate_id, :integer
  end

  def self.down
    remove_column :calais_related_searches, :affiliate_id
  end
end
