class CreateAutoRecalls < ActiveRecord::Migration
  def self.up
    create_table :auto_recalls do |t|
      t.integer :recall_id
      t.string :make, :limit => 25
      t.string :model
      t.integer :year
      t.string :component_description
      t.date :manufacturing_begin_date
      t.date :manufacturing_end_date
      t.string :manufacturer, :limit => 40
      t.string :recalled_component_id      
      t.timestamps
    end
    add_index :auto_recalls, :recall_id, :unique => false
  end

  def self.down
    drop_table :auto_recalls
  end
end
