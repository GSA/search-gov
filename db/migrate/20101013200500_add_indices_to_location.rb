class AddIndicesToLocation < ActiveRecord::Migration
  def self.up
    add_index :locations, :zip_code, :unique => true
    add_index :locations, :state
    add_index :locations, :city
  end

  def self.down
    remove_index :locations, :zip_code
    remove_index :locations, :state
    remove_index :locations, :city
  end
end
