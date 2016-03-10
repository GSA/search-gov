class RemoveTemplateableColumnsFromTemplates < ActiveRecord::Migration
  def change
    remove_column :templates, :templateable_type
    remove_column :templates, :templateable_id
    remove_column :templates, :selected
  end
end
