class CreateSearchgovDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :searchgov_documents do |t|
      t.text :web_document, null: false, size: :long
      t.json :headers, null: false
      t.decimal :tika_version, precision: 10, scale: 4, default: nil

      t.timestamps

      t.references :searchgov_url, foreign_key: true, type: :int
    end
  end
end
