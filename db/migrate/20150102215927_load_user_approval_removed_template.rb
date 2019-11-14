class LoadUserApprovalRemovedTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['user_approval_removed'])
  end

  def down
    EmailTemplate.where(name: 'user_approval_removed').delete_all
  end
end
