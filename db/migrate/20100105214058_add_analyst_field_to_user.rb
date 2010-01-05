class AddAnalystFieldToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_analyst, :boolean, :null=> false, :default => false
  end

  def self.down
    remove_column :users, :is_analyst
  end
end
