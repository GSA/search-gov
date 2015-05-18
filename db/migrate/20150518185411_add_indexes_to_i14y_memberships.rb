class AddIndexesToI14yMemberships < ActiveRecord::Migration
  def change
    add_index :i14y_memberships, :i14y_drawer_id
    add_index :i14y_memberships, [:affiliate_id, :i14y_drawer_id], :unique => true
  end
end
