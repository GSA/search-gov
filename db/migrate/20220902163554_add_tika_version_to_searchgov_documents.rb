class AddTikaVersionToSearchgovDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :searchgov_documents, :tika_version, :string, default: nil
  end
end
