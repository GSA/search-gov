class AddIndexesToProfiles < ActiveRecord::Migration
  def self.up
    add_index :flickr_profiles, :affiliate_id
    add_index :youtube_profiles, :affiliate_id
    add_index :facebook_profiles, :affiliate_id
  end

  def self.down
    remove_index :facebook_profiles, :affiliate_id
    remove_index :youtube_profiles, :affiliate_id
    remove_index :flickr_profiles, :affiliate_id
  end
end
