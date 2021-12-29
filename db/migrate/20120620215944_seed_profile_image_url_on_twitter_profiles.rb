class SeedProfileImageUrlOnTwitterProfiles < ActiveRecord::Migration
  def self.up
    TwitterProfile.all.each do |tp|
      twitter_user = Twitter.user(tp.screen_name) rescue nil
      tp.update!(:profile_image_url => twitter_user.profile_image_url) if twitter_user
    end
  end

  def self.down
  end
end
