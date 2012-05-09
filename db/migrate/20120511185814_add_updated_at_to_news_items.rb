class AddUpdatedAtToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :updated_at, :datetime
  end

  def self.down
    remove_column :news_items, :updated_at
  end
end
