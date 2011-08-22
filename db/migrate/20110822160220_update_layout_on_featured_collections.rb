class UpdateLayoutOnFeaturedCollections < ActiveRecord::Migration
  def self.up
    update "update featured_collections set layout = 'one column' where layout = '' OR layout IS NULL"
  end

  def self.down
  end
end
