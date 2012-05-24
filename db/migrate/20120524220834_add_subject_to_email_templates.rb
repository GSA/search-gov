class AddSubjectToEmailTemplates < ActiveRecord::Migration
  def self.up
    add_column :email_templates, :subject, :string
  end

  def self.down
    remove_column :email_templates, :subject
  end
end
