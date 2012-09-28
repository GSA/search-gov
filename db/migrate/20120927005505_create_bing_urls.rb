class CreateBingUrls < ActiveRecord::Migration
  def change
    create_table :bing_urls do |t|
      t.string :normalized_url, :null => false, :limit => 2000
      t.timestamps
    end
    add_index :bing_urls, :normalized_url
    add_index :bing_urls, :updated_at
  end
end
