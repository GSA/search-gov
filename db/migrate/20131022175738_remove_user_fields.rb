class RemoveUserFields < ActiveRecord::Migration
  def up
    remove_columns :users, [:time_zone, :phone, :address, :address2, :city, :state, :zip]
  end

  def down
    add_column :users, :time_zone, :string, default: "Eastern Time (US & Canada)", null: false
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
  end
end
