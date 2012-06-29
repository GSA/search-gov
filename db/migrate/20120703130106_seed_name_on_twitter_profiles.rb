class SeedNameOnTwitterProfiles < ActiveRecord::Migration
  def self.up
    TwitterProfile.all.each do |profile|
      twitter_user = Twitter.user(profile.screen_name) rescue nil
      profile.name = twitter_user.name
      profile.save
    end
  end

  def self.down
  end
end
