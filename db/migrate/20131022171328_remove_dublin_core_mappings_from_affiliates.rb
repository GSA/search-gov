class RemoveDublinCoreMappingsFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :dublin_core_mappings
  end

  def down
    add_column :affiliates, :dublin_core_mappings, :text
  end
end
