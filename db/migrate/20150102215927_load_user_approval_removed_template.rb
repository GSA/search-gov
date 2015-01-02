class LoadUserApprovalRemovedTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['user_approval_removed'])
  end

  def down
    EmailTemplate.delete_all(:name => 'user_approval_removed')
  end
end
