class AddApiKeyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :api_key, :string, :limit => 32
    User.all.each do |user|
      user.save
    end
  end

  def self.down
    remove_column :users, :api_key
  end
end
