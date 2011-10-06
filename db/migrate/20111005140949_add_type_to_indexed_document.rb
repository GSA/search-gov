class AddTypeToIndexedDocument < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :doctype, :string, :limit => 10, :default => 'html'
  end

  def self.down
    remove_column :indexed_documents, :doctype
  end
end
