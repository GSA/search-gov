class RenameSearchConsumerTemplateableTypeToTemplateableType < ActiveRecord::Migration
  def change
    rename_column :search_consumer_templates, :search_consumer_templateable_type, :templateable_type
    rename_column :search_consumer_templates, :search_consumer_templateable_id, :templateable_id
  end

  
end
