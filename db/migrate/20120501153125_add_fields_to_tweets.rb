class AddFieldsToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :published_at, :timestamp
  end

  def self.down
    remove_column :tweets, :published_at
  end
end
