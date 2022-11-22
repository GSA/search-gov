class ChangeDefaultIsBingImageSearchEnabledOnAffiliatesToFalse < ActiveRecord::Migration[6.1]
  def up
    change_column_default :affiliates, :is_bing_image_search_enabled, false
  end

  def down
    change_column_default :affiliates, :is_bing_image_search_enabled, true
  end
end
