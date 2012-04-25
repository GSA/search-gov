class CreateAffiliatesTwitterProfilesTable < ActiveRecord::Migration
  def self.up
    create_table :affiliates_twitter_profiles, :id => false do |t|
       t.integer :affiliate_id,   :null => false
       t.integer :twitter_profile_id, :null => false
    end
  end

  def self.down
    drop_table :affiliates_twitter_profiles
  end
end