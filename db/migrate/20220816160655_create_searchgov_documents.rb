class CreateSearchgovDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :searchgov_documents do |t|
      t.text :body, size: :long
      t.json :header
      t.integer :searchgov_url_id, unique: true

      t.timestamps

      t.foreign_key :searchgov_urls, column: :searchgov_url_id, primary_key: "id"
    end
  end
end
