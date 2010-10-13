class RemoveUniquenessFromZipCodeIndexOnLocations < ActiveRecord::Migration
  def self.up
    remove_index :locations, :zip_code
    add_index :locations, :zip_code
  end

  def self.down
    remove_index :locations, :zip_code
    add_index :locations, :zip_code, :unique => true
  end
end
