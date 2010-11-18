class AddIndexToUsersApiKey < ActiveRecord::Migration
  def self.up
    add_index :users, :api_key, :unique => true
  end

  def self.down
    remove_index :users, :api_key
  end
end
