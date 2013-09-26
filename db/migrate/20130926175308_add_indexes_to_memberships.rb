class AddIndexesToMemberships < ActiveRecord::Migration
  def change
    add_index :memberships, :user_id
    add_index :memberships, [:affiliate_id, :user_id], :unique => true
  end
end
