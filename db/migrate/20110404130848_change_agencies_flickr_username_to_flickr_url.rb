class ChangeAgenciesFlickrUsernameToFlickrUrl < ActiveRecord::Migration
  def self.up
    rename_column :agencies, :flickr_username, :flickr_url
    change_column :agencies, :flickr_url, :string, :limit => 255
  end

  def self.down
    change_column :agencies, :flickr_url, :string, :limit => 50
    rename_column :agencies, :flickr_url, :flickr_username
  end
end
