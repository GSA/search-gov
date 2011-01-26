class IndexUserOnAffiliatesUsers < ActiveRecord::Migration
  def self.up
    add_index :affiliates_users, :user_id
  end

  def self.down
    remove_index :affiliates_users, :user_id
  end
end
