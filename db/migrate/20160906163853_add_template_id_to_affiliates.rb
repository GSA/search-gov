class AddTemplateIdToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :template_id, :integer
    add_index :affiliates, :template_id
  end
end
