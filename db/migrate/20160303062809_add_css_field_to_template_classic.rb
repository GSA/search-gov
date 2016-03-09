class AddCssFieldToTemplateClassic < ActiveRecord::Migration
  def change
    add_column :template_classics, :css_hash, :text
  end
end
