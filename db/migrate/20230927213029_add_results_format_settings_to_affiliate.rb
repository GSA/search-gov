class AddResultsFormatSettingsToAffiliate < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :display_image_on_search_results, :boolean, default:false, null: false
    add_column :affiliates, :display_filetype_on_search_results, :boolean, default:false, null: false
    add_column :affiliates, :display_created_date_on_search_results, :boolean, default:false, null: false
    add_column :affiliates, :display_updated_date_on_search_results, :boolean, default:false, null: false
  end
end
