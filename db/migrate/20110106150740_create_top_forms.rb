class CreateTopForms < ActiveRecord::Migration
  def self.up
    create_table :top_forms do |t|
      t.string :name
      t.text :url
      t.integer :column_number
      t.integer :sort_order
      t.timestamps
    end
    add_index :top_forms, :column_number, :unique => false
    add_index :top_forms, :sort_order, :unique => false
  end

  def self.down
    drop_table :top_forms
  end
end
