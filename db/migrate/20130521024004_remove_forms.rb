class RemoveForms < ActiveRecord::Migration
  def up
    drop_table :forms
    drop_table :gov_forms
    drop_table :form_agencies
    drop_table :affiliates_form_agencies
    drop_table :forms_indexed_documents
  end

  def down
    create_table :forms do |t|
      t.string :agency, :null => false
      t.string :number, :null => false
      t.string :url, :null => false
      t.string :file_type, :null => false
      t.text :details

      t.timestamps
    end

    add_index "forms", ["form_agency_id"], :name => "index_forms_on_form_agency_id"
    add_index "forms", ["title"], :name => "index_forms_on_title"

    create_table :gov_forms do |t|
      t.string :name, :null => false
      t.string :form_number, :null => false
      t.string :agency, :null => false
      t.string :bureau
      t.text :description
      t.string :url, :null => false
      t.timestamps
    end

    create_table "forms_indexed_documents", :id => false, :force => true do |t|
      t.integer "form_id",             :null => false
      t.integer "indexed_document_id", :null => false
    end

    add_index "forms_indexed_documents", ["form_id", "indexed_document_id"], :name => "forms_indexed_documents_on_foreign_keys", :unique => true

    create_table "affiliates_form_agencies", :id => false, :force => true do |t|
      t.integer "affiliate_id",   :null => false
      t.integer "form_agency_id", :null => false
    end

    add_index "affiliates_form_agencies", ["affiliate_id", "form_agency_id"], :name => "affiliates_form_agencies_on_foreign_keys", :unique => true

    create_table "form_agencies", :force => true do |t|
      t.string   "name",         :null => false
      t.string   "locale",       :null => false
      t.string   "display_name", :null => false
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

  end
end
