class CreateDocumentCollections < ActiveRecord::Migration
  def self.up
    create_table :document_collections do |t|
      t.references :affiliate, :null => false
      t.string :name, :null => false
      t.timestamps
    end
    add_index :document_collections, [:affiliate_id, :name], :unique => true
  end

  def self.down
    drop_table :document_collections
  end
end
