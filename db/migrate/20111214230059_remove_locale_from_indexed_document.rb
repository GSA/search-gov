class RemoveLocaleFromIndexedDocument < ActiveRecord::Migration
  def self.up
    remove_column :indexed_documents, :locale
  end

  def self.down
    add_column :indexed_documents, :locale, :string, :limit => 6, :null => false, :default => 'en'
  end
end
