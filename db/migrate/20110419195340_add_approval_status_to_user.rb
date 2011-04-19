class AddApprovalStatusToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :approval_status, :string, :null => false
    update("update users set approval_status = 'approved'")
  end

  def self.down
    remove_column :users, :approval_status
  end
end
