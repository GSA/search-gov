class AddLocaleToIndexedDocuments < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :locale, :string, :limit => 6, :null => false, :default => 'en'
  end

  def self.down
    remove_column :indexed_documents, :locale
  end
end
