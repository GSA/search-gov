class CreateSitePages < ActiveRecord::Migration
  def self.up
    create_table :site_pages do |t|
      t.string :url_slug
      t.string :title
      t.string :breadcrumb
      t.text :main_content

      t.timestamps
    end
    add_index :site_pages, :url_slug, :unique => true
  end

  def self.down
    drop_table :site_pages
  end
end
