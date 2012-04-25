class CreateCatalogPrefixes < ActiveRecord::Migration
  def self.up
    create_table :catalog_prefixes do |t|
      t.string :prefix, :null => false, :unique => true
      t.timestamps
    end
  end

  def self.down
    drop_table :catalog_prefixes
  end
end
