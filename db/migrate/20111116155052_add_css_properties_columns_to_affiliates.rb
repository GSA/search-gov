class AddCssPropertiesColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :css_properties, :text
    add_column :affiliates, :staged_css_properties, :text
  end

  def self.down
    remove_column :affiliates, :staged_css_properties
    remove_column :affiliates, :css_properties
  end
end
