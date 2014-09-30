class AddBodyToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :body, :longtext
  end
end
