class IndexAffiliateIdOnSuperfreshUrls < ActiveRecord::Migration
  def self.up
    add_index :superfresh_urls, :affiliate_id
  end

  def self.down
    remove_index :superfresh_urls, :affiliate_id
  end
end