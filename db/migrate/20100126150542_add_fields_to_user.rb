class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :phone, :string
    add_column :users, :organization_name, :string
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
    change_column(:users, :is_affiliate, :boolean, :default => true, :null=> false)
  end

  def self.down
    remove_column :users, :phone
    remove_column :users, :organization_name
    remove_column :users, :address
    remove_column :users, :address2
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :zip
    change_column(:users, :is_affiliate, :boolean, :default => false, :null=> false)      
  end
end
