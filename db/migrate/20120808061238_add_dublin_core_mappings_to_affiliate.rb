class AddDublinCoreMappingsToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :dublin_core_mappings, :text
  end
end
