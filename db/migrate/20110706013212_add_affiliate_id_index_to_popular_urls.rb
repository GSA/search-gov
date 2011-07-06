class AddAffiliateIdIndexToPopularUrls < ActiveRecord::Migration
  def self.up
    add_index :popular_urls, :affiliate_id
  end

  def self.down
    remove_index :popular_urls, :affiliate_id
  end
end
