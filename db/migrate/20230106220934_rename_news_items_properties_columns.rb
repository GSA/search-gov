class RenameNewsItemsPropertiesColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :news_items, :properties, :unsafe_properties
    rename_column :news_items, :safe_properties, :properties
  end
end
