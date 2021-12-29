class MigrateSocialMediaFromHandlesToProfiles < ActiveRecord::Migration
  def self.up
    YoutubeProfile.after_create.clear
    Affiliate.all.each do |affiliate|
      affiliate.facebook_profiles.create(:username => affiliate.facebook_handle) if affiliate.facebook_handle
      affiliate.flickr_profiles.create(:url => affiliate.flickr_url) if affiliate.flickr_url
      affiliate.youtube_handles.each do |youtube_handle|
        affiliate.youtube_profiles.create(:username => youtube_handle)
      end unless affiliate.youtube_handles.blank? or affiliate.youtube_handles.empty?
    end
    remove_column :affiliates, :youtube_handles
    remove_column :affiliates, :twitter_handle
    remove_column :affiliates, :facebook_handle
    remove_column :affiliates, :flickr_url
    remove_column :flickr_photos, :affiliate_id
  end

  def self.down
    add_column :flickr_photos, :affiliate_id, :integer, :null => false
    add_column :affiliates, :flickr_url, :string
    add_column :affiliates, :facebook_handle, :string
    add_column :affiliates, :twitter_handle, :string
    add_column :affiliates, :youtube_handles, :string
    Affiliate.all.each do |affiliate|
      affiliate.update(:facebook_handle => affiliate.facebook_profiles.first.username) if affiliate.facebook_profiles.any?
      affiliate.update(:flickr_url => affiliate.flickr_profiles.first.url) if affiliate.flickr_profiles.any?
      affiliate.update(:twitter_handle => affiliate.twitter_profiles.first.screen_name) if affiliate.twitter_profiles.any?
      affiliate.update(:youtube_handles => affiliate.youtube_profiles.collect(&:username)) if affiliate.youtube_profiles.any?
    end
  end
end
