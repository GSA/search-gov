class CreateRecalls < ActiveRecord::Migration
  def self.up
    create_table :recalls do |t|
      t.integer :recall_number
      t.integer :y2k
      t.date :recalled_on

      t.timestamps
    end
    
    create_table :recall_details do |t|
      t.integer :recall_id
      t.string :detail_type
      t.string :detail_value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :recalls
    drop_table :recall_details
  end
end
