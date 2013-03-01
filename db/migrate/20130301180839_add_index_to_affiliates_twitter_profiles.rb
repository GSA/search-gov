class AddIndexToAffiliatesTwitterProfiles < ActiveRecord::Migration
  def change
    add_index :affiliates_twitter_profiles, [:affiliate_id, :twitter_profile_id], :name => 'aff_id_tp_id'
  end
end
