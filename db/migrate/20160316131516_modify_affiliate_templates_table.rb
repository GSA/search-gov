class ModifyAffiliateTemplatesTable < ActiveRecord::Migration
  def up
    remove_column :affiliate_templates, :name
    remove_column :affiliate_templates, :description
    remove_column :affiliate_templates, :stylesheet

    add_column :affiliate_templates, :affiliate_id, :integer, null: false
    add_column :affiliate_templates, :template_class, :string, null: false
    add_column :affiliate_templates, :available, :boolean, default: true, null: false

    add_index :affiliate_templates, [:affiliate_id, :template_class], unique: true
  end

  def down
    add_column :affiliate_templates, :name, :string
    add_column :affiliate_templates, :description, :string
    add_column :affiliate_templates, :stylesheet, :string

    remove_column :affiliate_templates, :affiliate_id
    remove_column :affiliate_templates, :template_class
    remove_column :affiliate_templates, :available
  end
end
