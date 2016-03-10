class RenameTemplateTypeOnAffiliate < ActiveRecord::Migration
  def up
    remove_column :affiliates, :template_type
    add_column :affiliates, :template_id, :integer
  end

  def down
    add_column :affiliates, :template_type, :string
    remove_column :affiliates, :template_id
  end
end
