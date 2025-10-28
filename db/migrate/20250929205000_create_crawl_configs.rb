class CreateCrawlConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :crawl_configs do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.string :allowed_domains, null: false, limit: 2048
      t.text :starting_urls, null: false
      t.text :sitemap_urls
      t.text :deny_paths

      t.integer :depth_limit, null: false, default: 3
      t.integer :sitemap_check_hours
      t.boolean :allow_query_string, null: false, default: false
      t.boolean :handle_javascript, null: false, default: false

      t.string :schedule, null: false
      t.string :output_target, null: false

      t.timestamps
    end

    add_index :crawl_configs, [:output_target, :allowed_domains], name: 'index_crawl_configs_on_output_target_and_allowed_domains', unique: true, length: { allowed_domains: 255 }
  end
end
