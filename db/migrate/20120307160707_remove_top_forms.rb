class RemoveTopForms < ActiveRecord::Migration
  def self.up
    drop_table :top_forms
  end

  def self.down
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
end
