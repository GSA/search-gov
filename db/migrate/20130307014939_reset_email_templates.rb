class ResetEmailTemplates < ActiveRecord::Migration
  def up
    EmailTemplate.delete_all(:name => 'objectionable_content_alert')
  end

  def down
  end
end
