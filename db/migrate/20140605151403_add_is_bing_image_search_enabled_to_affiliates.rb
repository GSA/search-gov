class AddIsBingImageSearchEnabledToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :is_bing_image_search_enabled, :boolean, default: false, null: false
  end
end
