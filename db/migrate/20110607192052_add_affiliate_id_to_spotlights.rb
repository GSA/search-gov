class AddAffiliateIdToSpotlights < ActiveRecord::Migration
  def self.up
    add_column :spotlights, :affiliate_id, :integer
  end

  def self.down
    remove_column :spotlights, :affiliate_id
  end
end
