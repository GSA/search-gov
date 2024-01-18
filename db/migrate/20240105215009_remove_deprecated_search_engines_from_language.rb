class RemoveDeprecatedSearchEnginesFromLanguage < ActiveRecord::Migration[7.0]
  def change
    remove_column :languages, :is_azure_supported, :boolean, default: false
    remove_column :languages, :is_google_supported, :boolean, default: false, null: false
  end
end
