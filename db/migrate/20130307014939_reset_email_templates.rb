class ResetEmailTemplates < ActiveRecord::Migration
  def up
    EmailTemplate.where(name: 'objectionable_content_alert').delete_all
  end

  def down
  end
end
