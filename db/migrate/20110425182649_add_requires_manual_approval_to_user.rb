class AddRequiresManualApprovalToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :requires_manual_approval, :boolean, :default => false
    update("update users set requires_manual_approval = true where approval_status = 'pending_approval'")
  end

  def self.down
    remove_column :users, :requires_manual_approval
  end
end
