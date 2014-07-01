class CreateFederalRegisterDocuments < ActiveRecord::Migration
  def change
    create_table :federal_register_documents do |t|
      t.string :document_number, null: false
      t.string :title, null: false
      t.string :abstract
      t.string :html_url, null: false
      t.string :document_type, null: false
      t.integer :start_page, null: false
      t.integer :end_page, null: false
      t.integer :page_length, null: false
      t.date :publication_date, null: false
      t.date :comments_close_on
      t.date :effective_on

      t.timestamps
    end
  end
end
