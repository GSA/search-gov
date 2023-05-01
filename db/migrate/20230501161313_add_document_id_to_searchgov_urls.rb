class AddDocumentIdToSearchgovUrls < ActiveRecord::Migration[7.0]
  def change
    add_column :searchgov_urls, :document_id, :string, limit: 64
  end
end
