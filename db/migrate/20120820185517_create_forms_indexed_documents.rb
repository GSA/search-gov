class CreateFormsIndexedDocuments < ActiveRecord::Migration
  def change
    create_table :forms_indexed_documents, :id => false do |t|
      t.references :form, :null => false
      t.references :indexed_document, :null => false
    end
    add_index :forms_indexed_documents, [:form_id, :indexed_document_id], :unique => true, :name => 'forms_indexed_documents_on_foreign_keys'
  end
end
