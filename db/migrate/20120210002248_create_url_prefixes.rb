class CreateUrlPrefixes < ActiveRecord::Migration
  def self.up
    create_table :url_prefixes do |t|
      t.references :document_collection, :null => false
      t.string :prefix, :null => false
      t.timestamps
    end
    add_index :url_prefixes, [:document_collection_id, :prefix], :unique => true
  end

  def self.down
    drop_table :url_prefixes
  end
end
