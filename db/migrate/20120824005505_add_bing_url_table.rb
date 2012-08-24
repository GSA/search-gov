class AddBingUrlTable < ActiveRecord::Migration
  def change
    create_table :bing_urls do |t|
      t.string :normalized_url, :null => false, :limit => 2000
      t.datetime :created_at, :null => false
    end
    add_index :bing_urls, :normalized_url
  end
end
