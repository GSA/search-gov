class ModifyFlickrPhotoToBelongToFlickrProfile < ActiveRecord::Migration
  def self.up
    add_column :flickr_photos, :flickr_profile_id, :integer
  end

  def self.down
    remove_column :flickr_photos, :flickr_profile_id
  end
end
