class RenameSocialMediaColumnsOnAffiliates < ActiveRecord::Migration
  def self.up
    change_table :affiliates do |t|
      t.rename :facebook_username, :facebook_handle
      t.rename :twitter_username, :twitter_handle
      t.rename :youtube_username, :youtube_handle
    end
  end

  def self.down
    change_table :affiliates do |t|
      t.rename :youtube_handle, :youtube_username
      t.rename :twitter_handle, :twitter_username
      t.rename :facebook_handle, :facebook_username
    end
  end
end
