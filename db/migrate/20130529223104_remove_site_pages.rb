class RemoveSitePages < ActiveRecord::Migration
  def up
    drop_table :site_pages
  end

  def down
    create_table "site_pages", :force => true do |t|
      t.string   "url_slug"
      t.string   "title"
      t.string   "breadcrumb",   :limit => 2048
      t.text     "main_content"
      t.datetime "created_at"
    end

    add_index "site_pages", ["url_slug"], :name => "index_site_pages_on_url_slug", :unique => true
  end
end
