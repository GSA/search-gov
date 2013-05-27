class AddPropertiesToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :properties, :text
  end
end
