class AddTemplateColumnsToAffiliate < ActiveRecord::Migration
  def change
  	add_column :affiliates, :active_template_id, :integer
    add_column :affiliates, :template_schema, :text

    add_index :affiliates, :active_template_id
  end
end
