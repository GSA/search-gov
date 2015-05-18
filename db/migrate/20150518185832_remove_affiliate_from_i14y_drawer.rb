class RemoveAffiliateFromI14yDrawer < ActiveRecord::Migration
  def up
    remove_column :i14y_drawers, :affiliate_id
  end

  def down
    add_column :i14y_drawers, :affiliate_id, :integer
  end
end
