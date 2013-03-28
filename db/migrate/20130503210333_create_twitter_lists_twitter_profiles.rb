class CreateTwitterListsTwitterProfiles < ActiveRecord::Migration
  def change
    create_table :twitter_lists_twitter_profiles, id: false do |t|
      t.references :twitter_list, limit: 8, null: false
      t.references :twitter_profile, null: false
    end
    add_index :twitter_lists_twitter_profiles, [:twitter_list_id, :twitter_profile_id], unique: true, name: 'twitter_list_id_profile_id'
    add_index :twitter_lists_twitter_profiles, :twitter_profile_id
  end
end