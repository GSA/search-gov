class AddIndexToSearchgovUrl < ActiveRecord::Migration[6.1]
  def change
    add_column :searchgov_urls, :document_id, :string
    add_index :searchgov_urls, :document_id, unique: true
  end
end
