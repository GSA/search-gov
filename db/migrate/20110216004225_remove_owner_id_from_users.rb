class RemoveOwnerIdFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :owner_id
  end

  def self.down
    add_column :affiliates, :owner_id, :integer, :default => nil
    add_index :affiliates, :owner_id, :unique => false
  end
end
