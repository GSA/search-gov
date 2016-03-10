class AddTemplateSchemaToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :schema, :text
  end
end
