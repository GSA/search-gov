class RenameSearchConsumerTemplatesToTemplates < ActiveRecord::Migration
  def change
    rename_table 'search_consumer_templates', 'templates'
  end
end
