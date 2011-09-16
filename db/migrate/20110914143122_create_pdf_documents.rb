class CreatePdfDocuments < ActiveRecord::Migration
  def self.up
    create_table :pdf_documents do |t|
      t.string :title
      t.text :description
      t.text :keywords
      t.string :url
      t.references :affiliate

      t.timestamps
    end
  end

  def self.down
    drop_table :pdf_documents
  end
end
