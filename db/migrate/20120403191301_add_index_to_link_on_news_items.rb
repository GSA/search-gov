class AddIndexToLinkOnNewsItems < ActiveRecord::Migration
  def self.up
    add_index :news_items, :link, :unique => false
  end

  def self.down
    remove_index :news_items, :link
  end
end
