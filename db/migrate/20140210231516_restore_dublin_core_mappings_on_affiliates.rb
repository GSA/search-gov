class RestoreDublinCoreMappingsOnAffiliates < ActiveRecord::Migration
  def up
    add_column :affiliates, :dublin_core_mappings, :text
  end

  def down
    remove_column :affiliates, :dublin_core_mappings
  end
end
