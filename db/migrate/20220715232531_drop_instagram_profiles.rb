class DropInstagramProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :instagram_profiles
  end
end
