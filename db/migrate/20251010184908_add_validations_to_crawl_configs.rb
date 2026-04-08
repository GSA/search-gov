class AddValidationsToCrawlConfigs < ActiveRecord::Migration[7.1]
  def change
    # Add check constraint for depth_limit to be between 0 and 150
    add_check_constraint :crawl_configs, 'depth_limit >= 0 AND depth_limit <= 150', name: 'crawl_configs_depth_limit_range'

    # Add unique index for name field
    add_index :crawl_configs, :name, unique: true
  end
end
