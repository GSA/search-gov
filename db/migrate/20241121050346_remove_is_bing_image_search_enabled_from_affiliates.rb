class RemoveIsBingImageSearchEnabledFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    remove_column :affiliates, :is_bing_image_search_enabled, :boolean
  end
end
