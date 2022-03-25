class RemoveSearchConsumerColumnsFromAffiliates < ActiveRecord::Migration[6.1]
  def change
    remove_column :affiliates, :search_consumer_search_enabled, :boolean
    remove_column :affiliates, :active_template_id, :integer
    remove_column :affiliates, :template_schema, :text
    remove_column :affiliates, :template_id, :integer
  end
end
