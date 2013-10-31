class RefreshEmailTemplates < ActiveRecord::Migration
  def up
    EmailTemplate.delete_all
    EmailTemplate.load_default_templates
  end

  def down
  end
end
