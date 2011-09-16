class AddBodyToPdfDocuments < ActiveRecord::Migration
  def self.up
    add_column :pdf_documents, :body, :text
  end

  def self.down
    remove_column :pdf_documents, :body
  end
end
