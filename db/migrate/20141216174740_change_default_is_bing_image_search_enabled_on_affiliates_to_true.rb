class ChangeDefaultIsBingImageSearchEnabledOnAffiliatesToTrue < ActiveRecord::Migration
  def up
    change_column_default :affiliates, :is_bing_image_search_enabled, true
  end

  def down
    change_column_default :affiliates, :is_bing_image_search_enabled, false
  end
end
