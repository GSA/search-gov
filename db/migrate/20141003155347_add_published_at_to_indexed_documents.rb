class AddPublishedAtToIndexedDocuments < ActiveRecord::Migration
  def change
    add_column :indexed_documents, :published_at, :datetime
  end
end
