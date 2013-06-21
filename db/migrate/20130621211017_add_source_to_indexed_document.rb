class AddSourceToIndexedDocument < ActiveRecord::Migration
  def change
    add_column :indexed_documents, :source, :string, null: false, default: 'rss'
  end
end
