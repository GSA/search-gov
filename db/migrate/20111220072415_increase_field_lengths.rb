class IncreaseFieldLengths < ActiveRecord::Migration
  def self.up
    remove_index :indexed_documents, [:url, :affiliate_id]
    change_column :indexed_documents, :url, :string, :limit => 2000
    remove_index :indexed_documents, :affiliate_id
    add_index :indexed_documents, [:affiliate_id, :url], :name => 'by_aid_url', :length => {:url => 50}
    change_column :indexed_documents, :title, :text
  end

  def self.down
    change_column :indexed_documents, :title, :string
    remove_index :indexed_documents, :name => 'by_aid_url'
    add_index :indexed_documents, :affiliate_id
    change_column :indexed_documents, :url, :string
    add_index :indexed_documents, [:url, :affiliate_id], :unique => true
  end
end
