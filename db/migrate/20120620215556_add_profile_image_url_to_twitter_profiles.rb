class AddProfileImageUrlToTwitterProfiles < ActiveRecord::Migration
  def self.up
    add_column :twitter_profiles, :profile_image_url, :string, :null => false
  end

  def self.down
    remove_column :twitter_profiles, :profile_image_url
  end
end
