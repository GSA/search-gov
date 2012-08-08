class AddDublinCoreToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :contributor, :string
    add_column :news_items, :subject, :string
    add_column :news_items, :publisher, :string
  end
end
