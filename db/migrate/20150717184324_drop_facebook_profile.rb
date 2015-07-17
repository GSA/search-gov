class DropFacebookProfile < ActiveRecord::Migration
  def up
    drop_table :facebook_profiles
  end

  def down
  end
end
