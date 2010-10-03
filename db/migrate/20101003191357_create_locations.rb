class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer :zip_code
      t.string :state
      t.string :city
      t.integer :population
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
