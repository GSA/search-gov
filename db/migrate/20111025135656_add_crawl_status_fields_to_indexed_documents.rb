class AddCrawlStatusFieldsToIndexedDocuments < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :last_crawled_at, :timestamp, :default => nil
    add_column :indexed_documents, :last_crawl_status, :string, :default => nil
    add_index :indexed_documents, :affiliate_id
  end

  def self.down
    remove_index :indexed_documents, :affiliate_id
    remove_column :indexed_documents, :last_crawl_status
    remove_column :indexed_documents, :last_crawled_at
  end
end
