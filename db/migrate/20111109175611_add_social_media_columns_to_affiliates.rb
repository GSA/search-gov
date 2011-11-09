class AddSocialMediaColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :facebook_username, :string
    add_column :affiliates, :flickr_url, :string
    add_column :affiliates, :twitter_username, :string
    add_column :affiliates, :youtube_username, :string
  end

  def self.down
    remove_column :affiliates, :youtube_username
    remove_column :affiliates, :twitter_username
    remove_column :affiliates, :flickr_url
    remove_column :affiliates, :facebook_username
  end
end
