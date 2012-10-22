class AddIndexOnAffiliateIdAndTitleToBoostedContents < ActiveRecord::Migration
  def self.up
    remove_index :boosted_contents, :name => 'index_boosted_sites_on_affiliate_id'
    add_index :boosted_contents, [:affiliate_id, :title]
  end

  def self.down
    remove_index :boosted_contents, [:affiliate_id, :title]
    add_index :boosted_contents, :affiliate_id, :name => 'index_boosted_sites_on_affiliate_id'
  end
end
