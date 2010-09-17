class AddIsAnalystAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_analyst_admin, :boolean, :null=> false, :default => false
  end

  def self.down
    remove_column :users, :is_analyst_admin
  end
end
