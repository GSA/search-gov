class AddSearchLabelColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :default_search_label, :string, :limit => 20, :null => false
    add_column :affiliates, :image_search_label, :string, :limit => 20, :null => false

    update "UPDATE affiliates SET default_search_label = 'Everything' WHERE locale = 'en'"
    update "UPDATE affiliates SET default_search_label = 'Todo' WHERE locale = 'es'"

    update "UPDATE affiliates SET image_search_label = 'Images' WHERE locale = 'en'"
    update "UPDATE affiliates SET image_search_label = 'Imágenes' WHERE locale = 'es'"
  end

  def self.down
    remove_column :affiliates, :default_search_label
    remove_column :affiliates, :image_search_label
  end
end
