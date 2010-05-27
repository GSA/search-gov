class CreateMisspellings < ActiveRecord::Migration
  def self.up
    create_table :misspellings do |t|
      t.string :wrong
      t.string :rite

      t.timestamps
    end
    add_index :misspellings, :wrong
  end

  def self.down
    drop_table :misspellings
  end
end
